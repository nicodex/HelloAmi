#!/usr/bin/env python3

# https://www.python.org/dev/peps/pep-0343/#transition-plan
from __future__ import with_statement

import ctypes
import glob
import os
import subprocess
import sys
try:
    # https://docs.python.org/3.0/whatsnew/3.0.html#builtins
    from functools import reduce
except ImportError:
    pass


def as_uint32(a):
    return a & 0xFFFFFFFF

def uint32_addc(a, b):
    c = as_uint32(a) + as_uint32(b)
    if c > 0xFFFFFFFF:
        c += 1
    return as_uint32(c)

def uint32_not(a):
    return as_uint32(a) ^ 0xFFFFFFFF

TD_SECTOR = 512
BOOTSECTS = 2

class BootBlock(ctypes.BigEndianStructure):
    _fields_ = [
        ('disk_type', ctypes.c_uint32),
        ('checksum' , ctypes.c_uint32),
        ('dos_block', ctypes.c_uint32),
        ('entry'    , ctypes.c_uint32 * (((TD_SECTOR * BOOTSECTS) - 12) // 4))]
    @classmethod
    def from_rawio(cls, f):
        b = cls()
        if f.readinto(b) != ctypes.sizeof(cls):
            raise Exception('failed to read %s structure' % cls.__name__)
        return b
    def update_checksum(self):
        self.checksum = uint32_not(
            reduce(uint32_addc, self.entry,
                uint32_addc(self.disk_type, self.dos_block)))
        return self

assert ctypes.sizeof(BootBlock) == TD_SECTOR * BOOTSECTS

class BBlock0x:
    _BASE = 'BBlock0x'
    _VASM = os.path.join('vasm', 'vasmm68k_mot')
    @classmethod
    def basepath(cls):
        return cls._BASE.replace('/', os.sep)
    @staticmethod
    def dosverc(ver):
        return chr(ord('0') + ver)
    @classmethod
    def outpath(cls, ver):
        o = cls.basepath()
        if ver != 0:
            o += '.dos' + cls.dosverc(ver)
        return o + '.bb'
    @classmethod
    def build(cls, ver):
        o = cls.outpath(ver);
        if not os.path.isfile(o):
            if not os.path.isfile(cls._VASM):
                for p in glob.glob(cls._VASM + '*'):
                    if os.access(p, os.X_OK):
                        cls._VASM = p
                        break
            subprocess.check_call(
                [cls._VASM, '-quiet',
                '-Fbin', '-pic', '-m68000', '-no-fpu', '-no-opt',
                '-DBBLOCK0X_DOSVER=' + cls.dosverc(ver),
                '-DBBLOCK0X_NOINFO=1',
                '-o', o, cls.basepath() + '.bb.asm'])
        with open(o, 'r+b') as f:
            b = BootBlock.from_rawio(f)
            c = b.checksum
            f.seek(0)
            f.write(b.update_checksum())
            if c != b.checksum:
                print('checksum updated: $%08X -> $%08X' % (c, b.checksum))
    @classmethod
    def clean(cls, ver):
        o = cls.outpath(ver);
        if os.path.isfile(o):
            os.remove(o)

def main(argv):
    r = range(0, 7 + 1)
    if (len(argv) > 1) and (argv[1] in ('clean', 'rebuild', 'all')):
        [BBlock0x.clean(v) for v in r]
    if (len(argv) <= 1) or (argv[1] in ('build', 'rebuild')):
        BBlock0x.build(0)
    if (len(argv) > 1) and (argv[1] in ('all')):
        [BBlock0x.build(v) for v in r]

if __name__ == '__main__':
    main(sys.argv)
