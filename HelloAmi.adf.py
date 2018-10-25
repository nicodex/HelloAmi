#!/usr/bin/env python

import calendar
import datetime
import decimal
import glob
import os
import string
import struct
import subprocess
import sys
import time
try:
    from functools import reduce
except ImportError:
    pass

sys.path.insert(0, 'python-cstruct')  # submodule
import cstruct  # https://pypi.org/project/cstruct/


AMIGA_EPOCH = int(
    calendar.timegm(
        datetime.datetime.strptime(
            '1978-01-01T00:00:00', '%Y-%m-%dT%H:%M:%S'
            ).utctimetuple()))

TICKS_PER_SECOND = 50

class DateStamp(cstruct.CStruct):
    __byte_order__ = cstruct.BIG_ENDIAN
    __struct__ = """
        uint32_t days;
        uint32_t minute;
        uint32_t tick;
    """
    
    def isoformat(self, sep='T', timespec='auto'):
        sep = 'T' if sep is None else chr(ord(sep))
        i = 0 if timespec is None else [
            'auto',          # 0
            'hours',         # 1
            'minutes',       # 2
            'seconds',       # 3
            'centiseconds',  # 4 (non-standard)
            'milliseconds',  # 5
            'microseconds'   # 6
            ].index(str(timespec))
        q, r = divmod(self.tick, TICKS_PER_SECOND)
        q += (self.minute * 60) + (self.days * 86400) + AMIGA_EPOCH
        if i <= 0:
            i = 3 if r == 0 else 6
        f = '%Y-%m-%d_%H'
        if i >= 2:
            f += ':%M'
            if i >= 3:
                f += ':%S'
        s = string.replace(time.strftime(f, time.gmtime(q)), '_', sep)
        if i >= 4:
            if i >= 5:
                if i >= 6:
                    return '%s.%06d' % (s, ((r * 1000000) // TICKS_PER_SECOND))
                return '%s.%03d' % (s, ((r * 1000) // TICKS_PER_SECOND))
            return '%s.%02d' % (s, (r * 100) // TICKS_PER_SECOND)
        return s

    @staticmethod
    def gmtime(secs=None):
        secs = time.time() if secs is None else float(secs)
        ds = DateStamp()
        d = decimal.Decimal('%.9f' % secs)
        if d > AMIGA_EPOCH:
            d -= AMIGA_EPOCH
            ds.days = int(d // 86400);
            d -= ds.days * 86400;
            ds.minute = int(d // 60);
            d -= ds.minute * 60;
            d *= TICKS_PER_SECOND
            ds.tick = int(d.to_integral(decimal.ROUND_DOWN));
        return ds


def as_uint32(a):
    return a & 0xFFFFFFFF

def uint32_add(a, b):
    return as_uint32(as_uint32(a) + as_uint32(b))

def uint32_addc(a, b):
    c = as_uint32(a) + as_uint32(b)
    if c > 0xFFFFFFFF:
        c += 1
    return as_uint32(c)

def uint32_neg(a):
    return as_uint32(-a)

def uint32_not(a):
    return as_uint32(a) ^ 0xFFFFFFFF


NUMCYLS = 80
NUMHEADS = 2
NUMSECS = 11
NUMTRACKS = NUMCYLS * NUMHEADS
TD_SECTOR = 512
BOOTSECTS = 2
BBNAME_DOS = 0x444F5300  # 'DOS\0' (OFS)

cstruct.define('BBENTRY_LEN', int(((TD_SECTOR * BOOTSECTS) - 12) // 4))

class BootBlock(cstruct.CStruct):
    __byte_order__ = cstruct.BIG_ENDIAN
    __struct__ = """
        uint32_t disk_type;
        uint32_t chksum;
        uint32_t dos_block;
        uint32_t entry[BBENTRY_LEN];
    """
    
    @property
    def checksum(self):
        return self.chksum
    
    def update_checksum(self):
        self.chksum = uint32_not(
            reduce(uint32_addc, self.entry,
                uint32_addc(self.disk_type, self.dos_block)))
        return self

assert BootBlock.size == TD_SECTOR * BOOTSECTS


def adf_checksum(block):
    f = '>%dI' % int(block.size // 4)
    return uint32_neg(
        reduce(uint32_add, struct.unpack(f, block.pack()),
            uint32_neg(block.checksum)))


BITMAP_LEN = int((((NUMTRACKS * NUMSECS) - BOOTSECTS) - 1) // 32) + 1
cstruct.define('BITMAP_LEN', BITMAP_LEN)
cstruct.define('BITMAP_RES', int(TD_SECTOR // 4) - 1 - BITMAP_LEN)

class BitmapBlock(cstruct.CStruct):
    __byte_order__ = cstruct.BIG_ENDIAN
    __struct__ = """
        uint32_t checksum;
        uint32_t bitmap[BITMAP_LEN];
        uint32_t reserved[BITMAP_RES];
    """
    
    def update_checksum(self):
        self.checksum = adf_checksum(self)
        return self
    
    def __getitem__(self, key):
        i, b = divmod(int(key) - BOOTSECTS, 32)
        return bool(self.bitmap[i] & (1 << b))
    
    def __setitem__(self, key, free):
        i, b = divmod(int(key) - BOOTSECTS, 32)
        if free:
            self.bitmap[i] |= 1 << b
        else:
            self.bitmap[i] &= uint32_not(1 << b)
    
    @property
    def next_free(self):
        for key in range((NUMTRACKS * NUMSECS) // 2, NUMTRACKS * NUMSECS):
            if self.__getitem__(key):
                return key
        for key in range(BOOTSECTS, (NUMTRACKS * NUMSECS) // 2):
            if self.__getitem__(key):
                return key
        return None
    
    def use_next(self):
        key = self.next_free
        if key is None:
            raise Exception('disk is full')
        self.__setitem__(key, False)
        return key

assert BitmapBlock.size == TD_SECTOR


T_SHORT = 2  # RootBlock, UserDirectoryBlock, FileHeaderBlock
T_DATA  = 8  # FileDataBlock

class BlockHeader(cstruct.CStruct):
    __byte_order__ = cstruct.BIG_ENDIAN
    __struct__ = """
        uint32_t block_type;
        uint32_t own_key;
        uint32_t seq_num;
        uint32_t data_size;
        uint32_t next_block;
        uint32_t checksum;
    """


TD_HTSIZE = int((TD_SECTOR - 200 - BlockHeader.size) // 4)
cstruct.define('TD_HTSIZE', TD_HTSIZE)

def ofs_toupper(c):
    if (0x61 <= c) and (c <= 0x7A):
        return c - 0x20
    return c

class OFSName(cstruct.CStruct):
    __byte_order__ = cstruct.BIG_ENDIAN
    __struct__ = """
        uint8_t length;
        uint8_t buffer[30];
        uint8_t reserved[5];
    """
    
    def get_string(self):
        return ''.join(map(chr, self.buffer[:self.length]))
    
    def set_string(self, s):
        if len(s) > len(self.buffer):
            raise Exception('name too long')
        self.clear()
        self.length = len(s)
        for i in range(self.length):
            self.buffer[i] = ord(chr(ord(s[i])))
    
    @staticmethod
    def from_string(s):
        n = OFSName()
        n.set_string(s)
        return n
    
    def __eq__(self, other):
        if not isinstance(other, self.__class__):
            other = from_string(str(other))
        if self.length != other.length:
            return False
        for i in range(self.length):
            if ofs_toupper(self.buffer[i]) != ofs_toupper(other.buffer[i]):
                return False
        return True
    
    def __ne__(self, other):
        return not self.__eq__(other)
    
    def __hash__(self):
        h = self.length
        for i in range(self.length):
            h *= 13
            h += ofs_toupper(self.buffer[i])
            h &= 0x07FF;
        return h % TD_HTSIZE


class AFSComment(cstruct.CStruct):
    __byte_order__ = cstruct.BIG_ENDIAN
    __struct__ = """
        uint8_t length;
        uint8_t buffer[79];
        uint8_t reserved[12];
    """
    
    def get_string(self):
        return ''.join(map(chr, self.buffer[:self.length]))
    
    def set_string(self, s):
        if len(s) > len(self.buffer):
            raise Exception('comment too long')
        self.clear()
        self.length = len(s)
        for i in range(self.length):
            self.buffer[i] = ord(chr(ord(s[i])))
    
    @staticmethod
    def from_string(s):
        c = AFSComment()
        c.set_string(s)
        return c


ST_ROOT = 1

cstruct.define('ROOT_BM_COUNT', 25)

class RootBlock(cstruct.CStruct):
    __byte_order__ = cstruct.BIG_ENDIAN
    __struct__ = """
        struct BlockHeader header;      /* [T_SHORT,0,0,len(hash_table),0,] */
        uint32_t           hash_table[TD_HTSIZE];
        int32_t            bitmap_flag;
        uint32_t           bitmap[ROOT_BM_COUNT];
        uint32_t           bit_extend;
        struct DateStamp   days;
        struct OFSName     name;
        uint32_t           link;        /* always 0 */
        struct DateStamp   disk_mod;
        struct DateStamp   create_days;
        uint32_t           hash_chain;  /* always 0 */
        uint32_t           parent;      /* always 0 */
        uint32_t           extension;
        int32_t            sub_type;    /* ST_ROOT */
    """
    
    @property
    def checksum(self):
        return self.header.checksum
    
    def update_checksum(self):
        self.header.checksum = adf_checksum(self);
        return self

assert RootBlock.size == TD_SECTOR


PROT_DELETE      = (1 <<  0)              # NOT deletable
PROT_EXECUTE     = (1 <<  1)              # NOT executable
PROT_WRITE       = (1 <<  2)              # NOT writable
PROT_READ        = (1 <<  3)              # NOT readable
PROT_ARCHIVE     = (1 <<  4)              # archived
PROT_PURE        = (1 <<  5)              # pure
PROT_SCRIPT      = (1 <<  6)              # script
PROT_HOLD        = (1 <<  7) | PROT_PURE  # hold (on first load)
PROT_GRP_DELETE  = (1 <<  8)              # group: NOT deletable
PROT_GRP_EXECUTE = (1 <<  9)              # group: executable
PROT_GRP_WRITE   = (1 << 10)              # group: writable
PROT_GRP_READ    = (1 << 11)              # group: readable
PROT_OTR_DELETE  = (1 << 12)              # other: NOT deletable
PROT_OTR_EXECUTE = (1 << 13)              # other: executable
PROT_OTR_WRITE   = (1 << 14)              # other: writable
PROT_OTR_READ    = (1 << 15)              # other: readable


ST_USERDIR = 2

class UserDirectoryBlock(cstruct.CStruct):
    __byte_order__ = cstruct.BIG_ENDIAN
    __struct__ = """
        struct BlockHeader header;      /* [T_SHORT,key,0,0,0,] */
        uint32_t           hash_table[TD_HTSIZE];
        uint32_t           bitmap_flag; /* reserved for RootBlock */
        uint16_t           owner_uid;
        uint16_t           owner_gid;
        uint32_t           protect;
        uint32_t           byte_size;  /* reserved for FileHeaderBlock */
        struct AFSComment  comment;
        struct DateStamp   days;
        struct OFSName     name;
        uint32_t           link;
        uint32_t           back_link;
        uint32_t           reserved[5]; /* reserved for RootBlock */
        uint32_t           hash_chain;
        uint32_t           parent;
        uint32_t           extension;
        int32_t            sub_type;    /* ST_USERDIR */
    """
    
    @property
    def key(self):
        return self.header.own_key

    @property
    def checksum(self):
        return self.header.checksum
    
    def update_checksum(self):
        self.header.checksum = adf_checksum(self);
        return self

assert UserDirectoryBlock.size == TD_SECTOR


ST_FILE = -3

class FileHeaderBlock(cstruct.CStruct):
    __byte_order__ = cstruct.BIG_ENDIAN
    __struct__ = """
        struct BlockHeader header;      /* [T_SHORT,key,blocks,slots,first,] */
        uint32_t           hash_table[TD_HTSIZE]; /* slot keys, rbegin..rend */
        uint32_t           bitmap_flag; /* reserved for RootBlock */
        uint16_t           owner_uid;
        uint16_t           owner_gid;
        uint32_t           protect;
        uint32_t           byte_size;
        struct AFSComment  comment;
        struct DateStamp   days;
        struct OFSName     name;
        uint32_t           link;
        uint32_t           back_link;
        uint32_t           reserved[5]; /* reserved for RootBlock */
        uint32_t           hash_chain;
        uint32_t           parent;
        uint32_t           extension;
        int32_t            sub_type;    /* ST_FILE */
    """
    
    @property
    def key(self):
        return self.header.own_key

    @property
    def checksum(self):
        return self.header.checksum
    
    def update_checksum(self):
        self.header.checksum = adf_checksum(self);
        return self

assert FileHeaderBlock.size == TD_SECTOR


OFSFILEDATA_SIZE = TD_SECTOR - BlockHeader.size
cstruct.define('OFSFILEDATA_SIZE', OFSFILEDATA_SIZE)

class FileDataBlock(cstruct.CStruct):
    __byte_order__ = cstruct.BIG_ENDIAN
    __struct__ = """
        struct BlockHeader header;      /* [T_DATA,key,block,size,next,] */
        uint8_t            file_data[OFSFILEDATA_SIZE];
    """
    
    @property
    def key(self):
        return self.header.own_key

    @property
    def checksum(self):
        return self.header.checksum
    
    def update_checksum(self):
        self.header.checksum = adf_checksum(self);
        return self

assert FileDataBlock.size == TD_SECTOR


class OFSDisk:
    def _read_block(self, cls, key):
        self._file.seek(key * TD_SECTOR)
        return cls(self._file.read(cls.size))
    
    def _write_block(self, key, block):
        self._file.seek(key * TD_SECTOR)
        self._file.write(block.update_checksum().pack())
    
    def _get_block(self, key):
        block = self._blocks.get(key)
        if block is None:
            if not key:
                block = self._read_block(BootBlock, key)
            else:
                block = self._read_block(FileHeaderBlock, key)
                if T_SHORT == block.header.block_type:
                    if ST_ROOT == block.sub_type:
                        block = RootBlock(block.pack())
                        block.key = key
                        if block.extension:
                            raise Exception(
                                'root extensions are not supported')
                    elif ST_USERDIR == block.sub_type:
                        block = UserDirectoryBlock(block.pack())
                        if block.extension:
                            raise Exception(
                                'dir extensions are not supported')
                    elif block.sub_type != ST_FILE:
                        raise Exception(
                            'unsupported short type %d in sector %d' %
                            (block.sub_type, key))
                elif T_DATA == block.header.block_type:
                    block = FileDataBlock(block.pack())
                else:
                    raise Exception(
                        'unsupported block type %d in sector %d' %
                        (block.header.block_type, key))
            checksum = block.checksum
            if checksum != block.update_checksum().checksum:
                print('checksum missmatch in block %d: $%08X -> $%08X' %
                    (key, checksum, block.checksum))
            self._blocks[key] = block
        return block
    
    def _get_path(self, block):
        path = ''
        if block.parent:
            path = block.name.get_string()
            block = self._get_block(block.parent)
            while block.parent:
                path = block.name.get_string() + '/' + path
                block = self._get_block(block.parent)
        return block.name.get_string() + ':' + path
    
    def __init__(self, file):
        self._file = open(file, 'r+b')
        self._blocks = {}
        self._boot = self._get_block(0)
        if ((self._boot.disk_type != BBNAME_DOS) or
            (self._boot.dos_block < BOOTSECTS) or
            (self._boot.dos_block >= NUMTRACKS * NUMSECS)):
            raise Exception('unsupported disk format')
        self._root = self._get_block(self._boot.dos_block)
        if (not isinstance(self._root, RootBlock) or
            (self._root.header.own_key != 0) or
            (self._root.header.seq_num != 0) or
            (self._root.header.data_size != TD_HTSIZE) or
            (self._root.bitmap_flag == 0) or
            (self._root.bitmap[0] == 0) or
            (max(self._root.bitmap[1:]) != 0)):
            raise Exception('unsupported root block')
        self._bitmap = self._read_block(BitmapBlock, self._root.bitmap[0])
        if ((self._bitmap.__getitem__(self._root.key)) or
            (self._bitmap.__getitem__(self._root.bitmap[0]))):
            raise Exception('invalid bitmap block')
        bitmap_checksum = self._bitmap.checksum
        if bitmap_checksum != self._bitmap.update_checksum().checksum:
            print('bitmap checksum missmatch: $%08X -> $%08X' %
                (bitmap_checksum, bitmap.checksum))
        self._blocks[self._root.bitmap[0]] = self._bitmap
    
    @property
    def root(self):
        return self._root
    
    def mkdir(self, dir, name, mdays=None):
        if dir is None:
            dir = self._root
        if mdays is None:
            mdays = DateStamp.gmtime()
        block = UserDirectoryBlock(
            header=BlockHeader(
                block_type=T_SHORT,
                own_key=self._bitmap.use_next()),
            protect=(
                PROT_ARCHIVE |
                PROT_GRP_EXECUTE | PROT_GRP_WRITE | PROT_GRP_READ |
                PROT_OTR_EXECUTE | PROT_OTR_WRITE | PROT_OTR_READ),
            days=mdays,
            parent=dir.key,
            sub_type=ST_USERDIR)
        block.name.set_string(name)
        name_hash = block.name.__hash__()
        prev_key = dir.hash_table[name_hash]
        if not prev_key:
            dir.hash_table[name_hash] = block.key
        else:
            while True:
                prev = self._get_block(prev_key)
                if prev.name.__eq__(block.name):
                    raise Exception('%s already exists' % self._get_path(block))
                prev_key = prev.hash_chain
                if not prev_key:
                    prev.hash_chain = block.key
                    break
        self._blocks[block.key] = block
        return block
    
    def add_file(self, dir, file, mdays=None, prot=None):
        if dir is None:
            dir = self._root
        file_path = file.replace('/', os.sep)
        file_name = os.path.split(file_path)[1]
        file_size = os.path.getsize(file_path)
        if mdays is None:
            mdays = DateStamp.gmtime(os.path.getmtime(file_path))
        if prot is None:
            prot = (
                PROT_EXECUTE |
                PROT_ARCHIVE |
                PROT_GRP_WRITE | PROT_GRP_READ |
                PROT_OTR_WRITE | PROT_OTR_READ)
        block_full, block_part = divmod(file_size, OFSFILEDATA_SIZE)
        block_count = block_full + bool(block_part)
        slot_count = min(TD_HTSIZE, block_count)
        if block_count > slot_count:
            raise Exception('file extension blocks are not implemented')
        head = FileHeaderBlock(
            header=BlockHeader(
                block_type=T_SHORT,
                own_key=self._bitmap.use_next(),
                seq_num=block_count,
                data_size=slot_count),
            protect=prot,
            byte_size=file_size,
            days=mdays,
            parent=dir.key,
            sub_type=ST_FILE)
        head.name.set_string(file_name)
        name_hash = head.name.__hash__()
        prev_key = dir.hash_table[name_hash]
        if not prev_key:
            dir.hash_table[name_hash] = head.key
        else:
            while True:
                prev = self._get_block(prev_key)
                if prev.name.__eq__(head.name):
                    raise Exception('%s already exists' % self._get_path(head))
                prev_key = prev.hash_chain
                if not prev_key:
                    prev.hash_chain = head.key
                    break
        self._blocks[head.key] = head
        f = open(file_path, 'rb')
        try:
            prev = head
            snum = 1
            left = file_size
            while left > 0:
                size = min(OFSFILEDATA_SIZE, left)
                data = FileDataBlock(
                    header=BlockHeader(
                        block_type=T_DATA,
                        own_key=self._bitmap.use_next(),
                        seq_num=snum,
                        data_size=size)
                    )
                fdata = struct.unpack('%dB' % data.header.data_size,
                    f.read(data.header.data_size))
                for b in range(len(fdata)):
                    data.file_data[b] = fdata[b]
                head.hash_table[TD_HTSIZE - snum] = data.key
                self._blocks[data.key] = data
                prev.header.next_block = data.key
                prev = data
                snum += 1
                left -= size
        finally:
            f.close()
        return head
    
    def save(self):
        for key, block in self._blocks.items():
            self._write_block(key, block)


class HelloAmi:
    _DRAWER, _ASMBIN, _ASMEXE, _SCRIPT = range(4)
    _FILE = 'HelloAmi.adf'
    _LIST = (
        (_ASMBIN, 'Disk.info'),
        (_ASMEXE, 'HelloAmi'),
        (_ASMBIN, 'HelloAmi.info'),
        (_DRAWER, 'C', (
            (_ASMEXE, 'C/LoadWB'),
            (_ASMEXE, 'C/EndCLI'),)),
        (_DRAWER, 'Devs', ()),
        (_DRAWER, 'Fonts', ()),
        (_DRAWER, 'Prefs', (
            (_DRAWER, 'Env-Archive', ()),)),
        (_DRAWER, 'S', (
            (_SCRIPT, 'S/Startup-Sequence'),)),
    )
    _vasmm68k_mot = os.path.join('vasm', 'vasmm68k_mot')
    @classmethod
    def _add(cls, adf, dir, item, mdays):
        t, n = item[:2]
        if cls._DRAWER == t:
            d = adf.mkdir(dir, n, mdays)
            for i in item[2]:
                cls._add(adf, d, i, mdays)
        elif cls._ASMBIN == t:
            cls._compile(n, t)
            adf.add_file(dir, n, mdays)
        elif cls._ASMEXE == t:
            cls._compile(n, t)
            adf.add_file(dir, n, mdays, (
                PROT_ARCHIVE | PROT_PURE |
                PROT_GRP_EXECUTE | PROT_GRP_WRITE | PROT_GRP_READ |
                PROT_OTR_EXECUTE | PROT_OTR_WRITE | PROT_OTR_READ))
        elif cls._SCRIPT == t:
            adf.add_file(dir, n, mdays, (
                PROT_EXECUTE | PROT_ARCHIVE | PROT_SCRIPT |
                PROT_GRP_WRITE | PROT_GRP_READ |
                PROT_OTR_WRITE | PROT_OTR_READ))
    @classmethod
    def _compile(cls, n, t):
        p = n.replace('/', os.sep)
        if not os.path.isfile(p):
            if not os.path.isfile(cls._vasmm68k_mot):
                for v in glob.glob(cls._vasmm68k_mot + '*'):
                    if os.access(v, os.X_OK):
                        cls._vasmm68k_mot = v
                        break
            subprocess.check_call([cls._vasmm68k_mot, '-quiet',
                '-Fbin' if cls._ASMBIN == t else '-Fhunkexe',
                '-o', p,
                p + '.asm'])
    @classmethod
    def _rm(cls, item):
        t, n = item[:2]
        if cls._DRAWER == t:
            for i in item[2]:
                cls._rm(i)
        elif t in (cls._ASMBIN, cls._ASMEXE):
            p = n.replace('/', os.sep)
            if os.path.isfile(p):
                os.remove(p)
    @classmethod
    def build(cls):
        cls._compile(cls._FILE, cls._ASMBIN)
        adf = OFSDisk(cls._FILE)
        dir, mdays = adf.root, DateStamp.gmtime()
        dir.days = dir.disk_mod = dir.create_days = mdays
        for item in cls._LIST:
            cls._add(adf, dir, item, mdays)
        adf.save()
    @classmethod
    def clean(cls):
        if os.path.isfile(cls._FILE):
            os.remove(cls._FILE)
        for i in cls._LIST:
            cls._rm(i)

def main(argv):
    if (len(argv) > 1) and (argv[1] in ('clean', 'rebuild')):
        HelloAmi.clean()
    if (len(argv) <= 1) or (argv[1] in ('build', 'rebuild')):
        HelloAmi.build()

if __name__ == '__main__':
    main(sys.argv)