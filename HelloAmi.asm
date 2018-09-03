; vasmm68k_mot -Fhunkexe -o HelloAmi -nosym HelloAmi.asm
start:
		movem.l	d2/d3/d4/d5/a2/a6,-(sp)
		moveq	#122,d3         ; ERROR_INVALID_RESIDENT_LIBRARY
		moveq	#0,d4           ; WBstartup message
		moveq	#0,d5           ; new console handle
		movea.l	(4).w,a6        ; AbsExecBase
		movea.l	$114(a6),a2     ; ThisTask
		tst.l	$AC(a2)         ; pr_CLI
		bne.b	.openDos
		lea	$5C(a2),a0      ; pr_MsgPort
		jsr	-$180(a6)       ; _LVOWaitPort
		lea	$5C(a2),a0      ; pr_MsgPort
		jsr	-$174(a6)       ; _LVOGetMsg
		move.l	d0,d4
.openDos:
		lea	.dosName(pc),a1
		jsr	-$198(a6)       ; _LVOOldOpenLibrary
		tst.l	d0
		beq.b	.replyMsg
		movea.l	d0,a6
		move.l	$A0(a2),d1      ; pr_COS
		bne.b	.writeTxt
		pea	.conSpec
		move.l	(sp)+,d1
		move.l	#1006,d2        ; MODE_NEWFILE
		jsr	-$1E(a6)        ; _LVOOpen
		move.l	d0,d5
		beq.b	.dosError
		move.l	d0,d1
.writeTxt:
		pea	.textStr
		move.l	(sp)+,d2
		moveq	#.textEnd-.textStr,d3
		jsr	-$30(a6)        ; _LVOWrite
		sub.l	d0,d3
		beq.b	.closeCon
.dosError:
		move.l	$94(a2),d3      ; pr_Result2 (IoErr)
.closeCon:
		tst.l	d5
		beq.b	.closeDos
		moveq	#127,d1
		jsr	-$C6(a6)        ; _LVODelay
		move.l	d5,d1
		jsr	-$24(a6)        ; _LVOClose
.closeDos:
		movea.l	a6,a1
		movea.l	(4).w,a6        ; AbsExecBase
		jsr	-$19E(a6)       ; _LVOCloseLibrary
.replyMsg:
		tst.l	d4
		beq.b	.result
		jsr	-$84(a6)        ; _LVOForbid
		movea.l	d4,a1
		jsr	-$17A(a6)       ; _LVOReplyMsg
.result:
		move.l	d3,$94(a2)      ; pr_Result2
		move.l	d3,d0
		beq.b	.return
		moveq	#20,d0          ; RETURN_FAIL
.return:
		movem.l	(sp)+,a6/a2/d5/d4/d3/d2
		rts
.conSpec:
.dosName:
		dc.b	"dos.library",0
.textStr:
		dc.b	"Hello World!",10
.textEnd:
		align	2
