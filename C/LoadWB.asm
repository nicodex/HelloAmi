; vasmm68k_mot[_<HOST>] -Fhunkexe -pic -nosym -o LoadWB LoadWB.asm
LoadWB:
		movem.l	d2-d5/a2-a6,-(sp)
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
.startWB:
		; avoid Alert(AN_Workbench!AG_OpenLib!AO_IconLib) on 1.x
		lea	.icnName(pc),a1
		jsr	-$0198(a6)      ; _LVOOldOpenLibrary
		tst.l	d0
		beq.b	.replyWB
		; test if Workbench task module is present
		lea	.wbtName(pc),a1
		jsr	-$0060(a6)      ; _LVOFindResident
		move.l	d0,d3
		beq.b	.replyWB
		; open dos.library
		lea	.dosName(pc),a1
		jsr	-$0198(a6)      ; _LVOOldOpenLibrary
		tst.l	d0
		beq.b	.replyWB
		movea.l	d0,a6
		; clear references (avoid inheritance)
		moveq	#-1,d1
		movea.l	$00B8(a2),a3    ; pr_WindowPtr
		move.l	d1,$00B8(a2)    ; pr_WindowPtr
		moveq	#0,d1           ; NULL
		movea.l	$00A4(a2),a4    ; pr_ConsoleTask
		move.l	d1,$00A4(a2)    ; pr_ConsoleTask
		movea.l	$00AC(a2),a5    ; pr_CLI
		move.l	d1,$00AC(a2)    ; pr_CLI
		jsr	-$007E(a6)      ; _LVOCurrentDir
		move.l	d0,-(sp)
		; create Workbench task
		pea	.wbtName(pc)
		move.l	(sp)+,d1
		moveq	#1,d2
		lsr.l	#2,d3
		addq.l	#($001A+2)/4,d3 ; RT_SIZE (BPTR-aligned)
		pea	(6144).w
		move.l	(sp)+,d4
		jsr	-$008A(a6)      ; _LVOCreateProc
		; restore references
		move.l	(sp)+,d1
		jsr	-$007E(a6)      ; _LVOCurrentDir
		move.l	a5,$00AC(a2)    ; pr_CLI
		move.l	a4,$00A4(a2)    ; pr_ConsoleTask
		move.l	a3,$00B8(a2)    ; pr_WindowPtr
		; close dos.library
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
		movem.l	(sp)+,d2-d5/a2-a6
		rts
.icnName:
		dc.b	"icon.library",0
.wbtName:
		dc.b	"workbench.task",0
.dosName:
		dc.b	"dos.library",0
	align	2
