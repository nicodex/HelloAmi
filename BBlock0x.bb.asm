; vasmm68k_mot -Fbin -pic -m68000 -no-fpu -no-opt -o BBlock0x.bb BBlock0x.bb.asm

	ifnd BBLOCK0X_DOSVER
	; ID_DOS_DISK         'DOS\0'
	; ID_FFS_DISK         'DOS\1'
	; ID_INTER_DOS_DISK   'DOS\2'
	; ID_INTER_FFS_DISK   'DOS\3'
	; ID_FASTDIR_DOS_DISK 'DOS\4'
	; ID_FASTDIR_FFS_DISK 'DOS\5'
	; ID_LNFS_DOS_DISK    'DOS\6'
	; ID_LNFS_FFS_DISK    'DOS\7'
BBLOCK0X_DOSVER EQU 0
	endif
	ifnd BBLOCK0X_NOINFO
BBLOCK0X_NOINFO EQU 1
	endif
	ifnd BBLOCK0X_CHKSUM
	ifeq BBLOCK0X_NOINFO
BBLOCK0X_CHKSUM EQU ~((~$830A73EC)+BBLOCK0X_DOSVER)
	else
BBLOCK0X_CHKSUM EQU ~((~$74A147A1)+BBLOCK0X_DOSVER)
	endif
	endif

BBlock0x:
		dc.b	'DOS',BBLOCK0X_DOSVER    ; BB_ID = BBID_DOS + version
		dc.l	BBLOCK0X_CHKSUM          ; BB_CHKSUM (BBlock0x.bb.py)
		dc.l	880                      ; BB_DOSBLOCK = dos root key
;
; BootBlock entry point
;
; 	Called by strap with SysBase in A6 and the I/O request in A1.
; 	Expects result in D0 (non-zero = AN_BootError) and boot code
; 	entry point address in A0. The boot code is called after the
; 	strap module freed all resources (includes this two sectors)!
;
; 	NOTE: The I/O request in A1 has to be preserved for 0.x ROMs.
;
		move.l	a1,-(sp)
		;
		; test SysBase version to avoid a deadlock with 0.x
		; (exec.library/OpenLibrary will freeze the system)
		;
		moveq	#37,d0
		cmp.w	$0014(a6),d0    ; LIB_VERSION
		bhi.b	.findDos
		;
		; this is part of the standard OS 2.x/3.x BootBlock
		; (SILENTSTART is disabled by default for floppies)
		;
		lea	.expName(pc),a1
		jsr	-$0228(a6)      ; _LVOOpenLibrary
		tst.l	d0
		beq.b	.findDos
		movea.l	d0,a1
		bset.b	#6,$0022(a1)    ; EBB_SILENTSTART,eb_Flags
		jsr	-$019E(a6)      ; _LVOCloseLibrary
.findDos:
		;
		; this is part of any standard BootBlock
		; (return the dos.library init function)
		;
		lea	.library(pc),a1
		pea	('dos.').l
		move.l	(sp)+,-(a1)
		jsr	-$0060(a6)      ; _LVOFindResident
		tst.l	d0
		movea.l	d0,a0
		beq.b	.bootErr
		move.l	$0016(a0),d0    ; RT_INIT
		movea.l	d0,a0
		beq.b	.bootErr
		moveq	#~0,d0
.bootErr:
		not.l	d0
		movea.l	(sp)+,a1
		rts
.expName:
		dc.b	"expansion."
.library:
		dc.b	"library",0
	align	1
BBInfo0x:
	ifeq BBLOCK0X_NOINFO
		dcb.b	2*512-(BBInfo0x-BBlock0x)-80,0
BBINFO0X_INFTD EQU ((2*512-(BBInfo0x-BBlock0x))/1000)
BBINFO0X_INFTM EQU ((2*512-(BBInfo0x-BBlock0x))-(1000*BBINFO0X_INFTD))
BBINFO0X_INFHD EQU (BBINFO0X_INFTM/100)
BBINFO0X_INFHM EQU (BBINFO0X_INFTM-(100*BBINFO0X_INFHD))
BBINFO0X_INFDD EQU (BBINFO0X_INFHM/10)
BBINFO0X_INFDM EQU (BBINFO0X_INFHM-(10*BBINFO0X_INFDD))
	ifeq BBINFO0X_INFTD
		dc.b	' '
	else
		dc.b	BBINFO0X_INFTD+'0'
	endif
	ifeq BBINFO0X_INFTD+BBINFO0X_INFHD
		dc.b	' '
	else
		dc.b	BBINFO0X_INFHD+'0'
	endif
	ifeq BBINFO0X_INFTD+BBINFO0X_INFHD+BBINFO0X_INFDD
		dc.b	' '
	else
		dc.b	BBINFO0X_INFDD+'0'
	endif
		dc.b	BBINFO0X_INFDM+'0'
		dc.b	    " bytes left "
		dc.b	" for boot block,"
		dc.b	" project at: htt"
		dc.b	"ps://github.com/"
		dc.b	"nicodex/HelloAmi"
	else
		dcb.b	2*512-(BBInfo0x-BBlock0x),0
	endif

	if *-BBlock0x-2*512
		fail "Unexpected boot block size, check your code."
	endif
