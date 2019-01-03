; vasmm68k_mot[_<HOST>] -Fhunkexe -pic -nosym -o HelloAmi HelloAmi.asm
HelloAmi:
		movem.l	d2-d5/a2/a6,-(sp)
		moveq	#122,d3         ; ERROR_INVALID_RESIDENT_LIBRARY
		moveq	#0,d4           ; WBStartup message
		moveq	#0,d5           ; new console handle
		movea.l	(4).w,a6        ; AbsExecBase
		; shortcut for exec.library/FindTask(0)
		movea.l	$0114(a6),a2    ; ThisTask
		tst.l	$00AC(a2)       ; pr_CLI
		bne.b	.openDos
		;
		; the Workbench sends a WBStartup message to our
		; message port on start - this message has to be
		; read before any dos.library function is called
		;
		lea	$005C(a2),a0    ; pr_MsgPort
		jsr	-$0180(a6)      ; _LVOWaitPort
		lea	$005C(a2),a0    ; pr_MsgPort
		jsr	-$0174(a6)      ; _LVOGetMsg
		move.l	d0,d4
.openDos:
		;
		; gain access to the "dos.library" (any version)
		;
		lea	.dosName(pc),a1
		jsr	-$0198(a6)      ; _LVOOldOpenLibrary
		tst.l	d0
		beq.b	.replyMsg
		movea.l	d0,a6
		;
		; use Output stream of our process (if assigned)
		;
		move.l	$00A0(a2),d1    ; pr_COS
		bne.b	.writeTxt
		;
		; else request a new window with the CON handler
		;
		pea	.conSpec
		move.l	(sp)+,d1
		move.l	#1006,d2        ; MODE_NEWFILE
		jsr	-$001E(a6)      ; _LVOOpen
		move.l	d0,d5
		beq.b	.dosError
		move.l	d0,d1
.writeTxt:
		;
		; D3 has been choosen for the extended exit code
		; to initialize it to zero (OK) while the result
		; of the dos.library/Write is tested for success
		;
		pea	.textStr
		move.l	(sp)+,d2
		moveq	#.textEnd-.textStr,d3
		jsr	-$0030(a6)      ; _LVOWrite
		sub.l	d0,d3
		beq.b	.closeCon
.dosError:
		; shortcut for dos.library/IoErr()
		move.l	$0094(a2),d3    ; pr_Result2
.closeCon:
		;
		; wait 2.5 s and close a newly opened CON window
		;
		tst.l	d5
		beq.b	.closeDos
		moveq	#125,d1
		jsr	-$00C6(a6)      ; _LVODelay
		move.l	d5,d1
		jsr	-$0024(a6)      ; _LVOClose
.closeDos:
		;
		; cleanup - conclude access to the "dos.library"
		;
		movea.l	a6,a1
		movea.l	(4).w,a6        ; AbsExecBase
		jsr	-$019E(a6)      ; _LVOCloseLibrary
.replyMsg:
		;
		; forbid task rescheduling if run from Workbench
		; (automatically broken/permitted on return) and
		; reply the WBStartup message that has been read
		;
		tst.l	d4
		beq.b	.result
		jsr	-$0084(a6)      ; _LVOForbid
		movea.l	d4,a1
		jsr	-$017A(a6)      ; _LVOReplyMsg
.result:
		; dos.library/SetIoErr() requires DOS version 36
		move.l	d3,$0094(a2)    ; pr_Result2
		move.l	d3,d0
		beq.b	.return
		moveq	#20,d0          ; RETURN_FAIL
.return:
		movem.l	(sp)+,d2-d5/a2/a6
		rts
.conSpec:
		; continued with .dosName as title to save bytes
		; (1.x CON handlers need non-empty width/height)
		dc.b	"CON:/9/253/79/"
.dosName:
		dc.b	"dos.library",0
.textStr:
		dc.b	"Hello, World!",10
.textEnd:
	align	2
