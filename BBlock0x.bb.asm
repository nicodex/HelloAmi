; vasmm68k_mot[_<HOST>] -Fbin -pic -o BBlock0x.bb BBlock0x.bb.asm
BBlock0x:
		dc.b	'DOS',0         ; BB_ID = BBID_DOS
		dc.l	$CE5BE1EC       ; BB_CHKSUM (BBlock0x.bb.py)
		dc.l	880             ; BB_DOSBLOCK = ST_ROOT sector
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
		bge.b	.findDos
		;
		; this is part of the standard OS 2.x/3.x BootBlock
		; (SILENTSTART is disabled by default for floppies)
		;
		lea	.expName,a1
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
		lea	.dosName(pc),a1
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
.dosName:
		dc.b	"dos.library",0
.expName:
		dc.b	"expansion.library",0
	align	1
BBInfo0x:
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

	if *-BBlock0x-2*512
		fail "Unexpected boot block size, check your code."
	endif
