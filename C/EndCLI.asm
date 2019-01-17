; vasmm68k_mot[_<HOST>] -Fhunkexe -pic -nosym -o EndCLI EndCLI.asm
EndCLI:
		movem.l	a2-a6/d2-d7,-(sp)
		movea.l	(4).w,a6        ; AbsExecBase
		movea.l	$0114(a6),a5    ; ThisTask
		move.l	$00AC(a5),d0    ; pr_CLI
		lsl.l	#2,d0
		movea.l	d0,a4
		bne.b	.openDos
		pea	(205).w         ; ERROR_OBJECT_NOT_FOUND
.result:
		move.l	(sp)+,d0
		move.l	d0,$0094(a5)    ; pr_Result2
		beq.b	.return
		moveq	#20,d0          ; RETURN_FAIL
.return:
		movem.l	(sp)+,d2-d7/a2-a6
		rts
.openDos:
		lea	.dosName(pc),a1
		jsr	-$0198(a6)      ; _LVOOldOpenLibrary
		tst.l	d0
		movea.l	d0,a6
		bne.b	.closeCLI
		pea	(122).w         ; ERROR_INVALID_RESIDENT_LIBRARY
		bra.b	.result
.closeCLI:
		;
		; Please note that the original EndCLI just sets fh_End = 0
		; to force continual EOF on rdch()/FGetC(), ignoring fh_Pos
		; (requires special handling in replenish() and other code).
		;
		lea	$001C(a4),a1    ; cli_StandardInput
		movea.l	(a1)+,a0
		lea	(a0,a0.l),a3
		clr.l	$0014(a3,a3.l)  ; fh_End
		;
		; The original EndCLI also sets background (reason unknown).
		;
		moveq	#-1,d0          ; DOSTRUE
		move.l	d0,$002C(a4)    ; cli_Background
		;
		; Starting with EndCLI from Workbench 1.1 the current input
		; is set to the default (terminal) input, and starting with
		; EndCLI from Workbench 1.2 the previous input is closed if
		; it is not already the default input. No version detection
		; here (seems to work fine with all tested ROM/WB versions).
		;
		cmpa.l	(a1),a0         ; (cli_CurrentInput)
		beq.b	.writeTxt
		move.l	(a1),d1
		move.l	a0,(a1)
		jsr	-$0024(a6)      ; _LVOClose
.writeTxt:
		move.l	a6,-(sp)
		tst.l	$0028(a4)       ; cli_Interactive
		beq.b	.closeDos
		move.l	#12+4,d0
		pea	.txtBSTR
		move.l	(sp)+,d1
		lsr.l	#2,d1
		move.l	$008C(a5),d2    ; pr_TaskNum
		suba.l	a0,a0
		movea.l	$003A(a5),a1    ; TC_SPLOWER
		movem.l	$002A(a6),a2/a5/a6 ; dl_A2/dl_A5/dl_A6
		movea.l	$0128(a2),a4    ; G_WRITEF
		jsr	(a5)
.closeDos:
		move.l	(sp)+,a1
		movea.l	(4).w,a6        ; AbsExecBase
		bsr.b	.cliSegUC
		jsr	-$019E(a6)      ; _LVOCloseLibrary
		pea	(0).w           ; RETURN_OK
		bra.b	.result
.cliSegUC:
		;
		; Starting with EndCLI from Workbench 1.2 the usage counter
		; of the resident "CLI" segment is decremented, if positive.
		;
		jsr	-$0084(a6)      ; _LVOForbid
		cmpi.w	#33,$0014(a1)   ; LIB_VERSION (requires DOS 1.2+)
		blo.b	.segDone
		movea.l	$0022(a1),a0    ; dl_Root
		movea.l	$0018(a0),a0    ; rn_Info
		adda.l	a0,a0
		lea	$0010(a0,a0.l),a0 ; di_NetHand
.segLoop:
		move.l	(a0),d0         ; seg_Next
		lsl.l	#2,d0
		movea.l	d0,a0
		beq.b	.segDone
		cmp.l	#$03434C49,$000C(a0) ; "\3CLI",seg_Name
		bne.b	.segLoop
		addq.l	#4,a0           ; seg_UC
		tst.l	(a0)
		ble.b	.segDone
		subq.l	#1,(a0)
.segDone:
		jmp	-$008A(a6)      ; _LVOPermit
.dosName:
		dc.b	"dos.library",0
	align	2
.txtBSTR:
		dc.b	22,"CLI process %N ending",10,0
	align	2
