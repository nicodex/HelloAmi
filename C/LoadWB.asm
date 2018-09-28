; vasmm68k_mot[_<HOST>] -Fhunkexe -pic -nosym -o LoadWB LoadWB.asm
LoadWB:
		movem.l	a6/a2/d5/d4/d3/d2,-(sp)
		moveq	#0,d5           ; WBStartup message
		movea.l	(4).w,a6        ; AbsExecBase
		movea.l	$0114(a6),a2    ; ThisTask
		tst.l	$00AC(a2)       ; pr_CLI
		bne.b	.startWB
		lea	$005C(a2),a0    ; pr_MsgPort
		jsr	-$0180(a6)      ; _LVOWaitPort
		lea	$005C(a2),a0    ; pr_MsgPort
		jsr	-$0174(a6)      ; _LVOGetMsg
		move.l	d0,d5
		;TODO: support AROS (workbench.library instead of .task)
		;TODO: avoid that Workbench process inherits CLI handles
.startWB:
		; avoid Alert(AN_Workbench!AG_OpenLib!AO_IconLib) on 1.x
		lea	.icnName(pc),a1
		jsr	-$0198(a6)      ; _LVOOldOpenLibrary
		tst.l	d0
		beq.b	.replyWB
		movea.l	d0,a1
		jsr	-$019E(a6)      ; _LVOCloseLibrary
		lea	.wbtName(pc),a1
		jsr	-$0060(a6)      ; _LVOFindResident
		move.l	d0,d3
		beq.b	.replyWB
		pea	.wbtName
		move.l	(sp)+,d1
		moveq	#1,d2
		lsr.l	#2,d3
		addq.l	#(2+$001A)/4,d3 ; RT_SIZE (BPTR-aligned)
		pea	(6144).w
		move.l	(sp)+,d4
		lea	.dosName(pc),a1
		jsr	-$0198(a6)      ; _LVOOldOpenLibrary
		tst.l	d0
		beq.b	.replyWB
		movea.l	d0,a6
		jsr	-$008A(a6)      ; _LVOCreateProc
		movea.l	a6,a1
		movea.l	(4).w,a6        ; AbsExecBase
		jsr	-$019E(a6)      ; _LVOCloseLibrary
.replyWB:
		tst.l	d5
		beq.b	.return0
		jsr	-$0084(a6)      ; _LVOForbid
		movea.l	d5,a1
		jsr	-$017A(a6)      ; _LVOReplyMsg
.return0:
		moveq	#0,d0           ; RETURN_OK
		movem.l	(sp)+,d2/d3/d4/d5/a2/a6
		rts
.icnName:
		dc.b	"icon.library",0
.wbtName:
		dc.b	"workbench.task",0
.dosName:
		dc.b	"dos.library",0
	align	2
