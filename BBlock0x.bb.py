#!/usr/bin/env python

from __future__ import with_statement

import ctypes
import glob
import os
import subprocess
import sys
try:
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
        ('chksum'   , ctypes.c_uint32),
        ('dos_block', ctypes.c_uint32),
        ('entry'    , ctypes.c_uint32 * (((TD_SECTOR * BOOTSECTS) - 12) // 4))]
    
    @classmethod
    def from_rawio(cls, f):
        b = cls()
        if f.readinto(b) != ctypes.sizeof(cls):
            raise Exception('failed to read %s structure' % cls.__name__)
        return b
    
    @property
    def checksum(self):
        return self.chksum
    
    def update_checksum(self):
        self.chksum = uint32_not(
            reduce(uint32_addc, self.entry,
                uint32_addc(self.disk_type, self.dos_block)))
        return self

assert ctypes.sizeof(BootBlock) == TD_SECTOR * BOOTSECTS

class BBlock0x:
    _FILE = 'BBlock0x.bb'
    _vasmm68k_mot = os.path.join('vasm', 'vasmm68k_mot')
    @classmethod
    def build(cls):
        p = cls._FILE.replace('/', os.sep)
        if not os.path.isfile(p):
            if not os.path.isfile(cls._vasmm68k_mot):
                for vasm in glob.glob(cls._vasmm68k_mot + '*'):
                    if os.access(vasm, os.X_OK):
                        cls._vasmm68k_mot = vasm
                        break
            subprocess.check_call(
                [cls._vasmm68k_mot, '-quiet',
                '-Fbin', '-m68000', '-no-fpu',
                '-o', p, p + '.asm'])
        with open(p, 'r+b') as f:
            b = BootBlock.from_rawio(f)
            c = b.checksum
            f.seek(0)
            f.write(b.update_checksum())
            if c != b.checksum:
                print('checksum updated: $%08X -> $%08X' % (c, b.checksum))
    @classmethod
    def clean(cls):
        if os.path.isfile(cls._FILE):
            os.remove(cls._FILE)

def main(argv):
    if (len(argv) > 1) and (argv[1] in ('clean', 'rebuild')):
        BBlock0x.clean()
    if (len(argv) <= 1) or (argv[1] in ('build', 'rebuild')):
        BBlock0x.build()

if __name__ == '__main__':
    main(sys.argv)
