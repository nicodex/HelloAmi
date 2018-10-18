; vasmm68k_mot[_<HOST>] -Fhunkexe -pic -nosym -o EndCLI EndCLI.asm
EndCLI:
		movem.l	a6/a5/a4/a3/a2/d3/d2,-(sp)
		movea.l	(4).w,a6        ; AbsExecBase
		movea.l	$0114(a6),a5    ; ThisTask
		move.l	$00AC(a5),d0    ; pr_CLI
		lsl.l	#2,d0
		movea.l	d0,a4
		bne.b	.openDos
		pea	(205).w         ; ERROR_OBJECT_NOT_FOUND
		lea	$005C(a5),a0    ; pr_MsgPort
		jsr	-$0180(a6)      ; _LVOWaitPort
		lea	$005C(a5),a0    ; pr_MsgPort
		jsr	-$0174(a6)      ; _LVOGetMsg
		move.l	d0,d2
		beq.b	.result
		jsr	-$0084(a6)      ; _LVOForbid
		movea.l	d2,a1
		jsr	-$017A(a6)      ; _LVOReplyMsg
.result:
		move.l	(sp)+,d0
		move.l	d0,$0094(a5)    ; pr_Result2
		beq.b	.return
		moveq	#20,d0          ; RETURN_FAIL
.return:
		movem.l	(sp)+,d2/d3/a2/a3/a4/a5/a6
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
		lea	$001C(a4),a1    ; cli_StandardInput
		move.l	(a1)+,a0
		lea	(a0,a0.l),a2
		clr.l	$0014(a2,a2.l)  ; fh_End
		moveq	#-1,d0
		move.l	d0,$002C(a4)    ; cli_Background
		cmpa.l	(a1),a0         ; (cli_CurrentInput)
		beq.b	.printTxt
		move.l	(a1),d1
		move.l	a0,(a1)
		jsr	-$0024(a6)      ; _LVOClose
.printTxt:
		move.l	a6,-(sp)
		movea.l	(4).w,a6        ; AbsExecBase
		tst.l	$0028(a4)       ; cli_Interactive
		beq.b	.closeDos
		lea	.endText(pc),a0
		lea	$008C(a5),a1    ; pr_TaskNum
		lea	.putChar(pc),a2
		move.l	$00A0(a5),-(sp) ; pr_COS
		movea.l	sp,a3
		jsr	-$020A(a6)      ; _LVORawDoFmt
		addq.l	#4,sp
.closeDos:
		movea.l	(sp)+,a1
		bsr.b	.cliSegUC
		jsr	-$019E(a6)      ; _LVOCloseLibrary
		pea	(0).w           ; RETURN_OK
		bra.b	.result
.putChar:
		movem.l	a6/a3/a1/a0/d3/d2/d1/d0,-(sp)
		tst.b	d0
		beq.b	.putSkip
		move.l	(a3)+,d1
		beq.b	.putSkip
		move.l	sp,d2
		add.l	#3,d2
		moveq	#1,d3
		movea.l	(a3),a6
		jsr	-$0030(a6)      ; _LVOWrite
.putSkip:
		movem.l	(sp)+,d0/d1/d2/d3/a0/a1/a3/a6
		rts
.cliSegUC:
		jsr	-$0084(a6)      ; _LVOForbid
		cmpi.w	#33,$0014(a1)   ; LIB_VERSION (1.2)
		blt.b	.segDone
		movea.l	$0022(a1),a0    ; dl_Root
		movea.l	$0018(a0),a0    ; rn_Info
		adda.l	a0,a0
		lea	$0010(a0,a0.l),a0 ; di_NetHand
.segLoop:
		move.l	(a0),d0         ; seg_Next
		lsl.l	#2,d0
		movea.l	d0,a0
		beq.b	.segDone
		cmp.l	#$03434C49,$000C(a0) ; seg_Name (3,"CLI")
		bne.b	.segLoop
		addq.l	#4,a0           ; seg_UC
		tst.l	(a0)
		ble.b	.segDone
		subq.l	#1,(a0)
.segDone:
		jmp	-$008A(a6)      ; _LVOPermit
.endText:
		dc.b	"CLI process %ld ending",10,0
.dosName:
		dc.b	"dos.library",0
	align	2
