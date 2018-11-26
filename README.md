HelloAmi
========

Just another "Hello, World!" for AmigaDOS in assembler.


About
-----

This project contains some basic classic Amiga (1.0-3.1) examples:  
  - `HelloAmi.asm`  
    Combined CLI and Workbench program, that prints "Hello, World!"
    on the console (requests a new console window if run from WB).
  - `HelloAmi.adf.asm`  
    OFS disk image with a custom boot sector, that creates a task that
    uses the `intuition.library` to show a window with a "Hello, World!"
    button (very early in the boot process, even before DOS is ready).
  - `C/LoadWB.asm`  
    Very simple re-implementation of the original program with the same name
    that starts the Workbench (does not support any arguments, always returns
    RETURN_OK, only supports the `workbench.task` method, and still has some
    issues - like possible inheritance of the current console handles).
  - `C/EndCLI.asm`  
    Re-implementation of the original program with the same name that closes
    the current CLI. This allows you to close the initial CLI after booting
    with a 1.x ROM (starting with 2.x ROMs `EndCLI` is an internal command).
  - `Libs/version.library`  
    Starting with the 1.2 ROM/Workbench this library is used by the `C/Version`
    tool and the Workbench/About requester (Special/Version in 1.x Workbench)
    to determine the version of the Workbench. Instead of a fixed major and
    revision number, this library dynamically sets its own version number at
    runtime (based on the currently loaded `workbench.library`, or the
    resident `workbench.task` module, or the Kickstart version).


Build
-----

Dependencies:
  - [vasm](http://sun.hasenbraten.de/vasm/) for `m68k` with `mot` syntax  
    Extract the vasm source code into the project directory (this is expected
    to result in a new subdirectory `vasm`) and follow the compilation
    instructions to build vasm for the Motorola 68000 CPU series with
    the Motorola syntax module (`make CPU=m68k SYNTAX=mot`). In the end,
    the build script expects to find the compiler executable with
    `vasm/vasmm68k_mot*` (e.g. `vasm\vasmm68k_mot_win32.exe` on Windows).
  - [Python](https://www.python.org/) 2.5 or newer and the
    [python-cstruct](https://github.com/nicodex/python-cstruct) submodule  
    I created my own fork, because the build script requires some features
    that have been introduced after the official v1.7 release (uintX_t types)
    and I still need Python 2.5 support (expected to be dropped upstream).

No external headers or include files (e.g. Amiga NDK) are required
because all used offsets and constants are hard-coded in the source.

To compile all sources and build the disk image, just
run the following command in the project directory:  
`python HelloAmi.adf.py rebuild`

If you want to use another assembler compiler/linker:  
  - `python HelloAmi.adf.py clean`
  - compile/link all *.asm
  - `python HelloAmi.adf.py build`


Tests
-----

The binaries and the disk image have been tested with the following ROMs
(included in [Amiga Forever](https://www.amigaforever.com/) 7 Plus Edition):

| ROM                       | BootBlock | HelloAmi | C/EndCLI | C/LoadWB |
|:--------------------------|:---------:|:--------:|:--------:|:--------:|
| `amiga-os-070.rom`        |     -     |          |          |          |
| `amiga-os-100.rom`        |     +     |    +     |    +     |    *     |
| `amiga-os-110-ntsc.rom`   |     +     |    +     |    +     |    *     |
| `amiga-os-110-pal.rom`    |     +     |    +     |    +     |    *     |
| `amiga-os-120.rom`        |     +     |    +     |    +     |    *     |
| `amiga-os-130.rom`        |     +     |    +     |    +     |    *     |
| `amiga-os-130-a3000.rom`  |     +     |    +     |    +     |    *     |
| `amiga-os-204.rom`        |     +     |    +     |    +     |    +     |
| `amiga-os-204-a3000.rom`  |     +     |    +     |    +     |    +     |
| `amiga-os-205-a600.rom`   |     +     |    +     |    +     |    +     |
| `amiga-os-300-a1200.rom`  |     +     |    +     |    +     |    +     |
| `amiga-os-300-a4000.rom`  |     +     |    +     |    +     |    +     |
| `amiga-os-310-a600.rom`   |     +     |    +     |    +     |    +     |
| `amiga-os-310-a1200.rom`  |     +     |    +     |    +     |    +     |
| `amiga-os-310-a3000.rom`  |     +     |    +     |    +     |    +     |
| `amiga-os-310-a4000.rom`  |     +     |    +     |    +     |    +     |
| `amiga-os-310-a4000t.rom` |     +     |    +     |    +     |    **    |
| `amiga-os-320-walker.rom` |     +     |    +     |    +     |    +     |
| `aros-20170328[-ext].rom` |     +     |    +     |    -     |    +     |
| `internal` ***            |     +     |    +     |    -     |    +     |

  - `*` requires `Libs/icon.library` on disk (not included in ROM)
  - `**` requires `Libs/workbench.library` on disk (not included in ROM)  
    Can be downloaded for free from the
    [Cloanto Web Workbench](https://www.amigaforever.com/classic/)
    (but note that 45.127 does not work with the tested AROS versions)
  - `***` as of this writing AROS `Version SVN50730, built on 2015-05-20`

For an unknown reason the boot block doesn't work with the 0.7 (beta) ROM.
Test configurations for [FS-UAE](https://fs-uae.net/) are included in
`test/fs-uae/` (you might have to import the Amiga Forever ROMs first).
The Amiga Forever `3.X` ROMs have not been tested, because the
`workbench.library` is missing (like in the `amiga-os-310-a4000t.rom`).


Legal
-----

HelloAmi is free software and released under The MIT License (MIT).
