; vasmm68k_mot[_<HOST>] -Fhunkexe -kick1hunks -nosym -o version.library version.library.asm
;
; 	The LIB_VERSION/LIB_REVISION of Libs/version.library
; 	is used by the Version tool and the Workbench About
; 	requester to display the Workbench version string.
;
VersionLibrary:
		moveq	#-1,d0
		rts
.ResTag:
		dc.w	$4AFC           ; RT_MATCHWORD = RTC_MATCHWORD
		dc.l	.ResTag         ; RT_MATCHTAG
		dc.l	.ResEnd         ; RT_ENDSKIP
		dc.b	$80             ; RT_FLAGS = RTF_AUTOINIT
		dc.b	0               ; RT_VERSION
		dc.b	9               ; RT_TYPE = NT_LIBRARY
		dc.b	0               ; RT_PRI
		dc.l	.ResName        ; RT_NAME
		dc.l	.ResVers        ; RT_IDSTRING
		dc.l	.ResAuto        ; RT_INIT
.ResName:
		dc.b	"version.library",0
		dc.b	"$VER: "
.ResVers:
		dc.b	"wbver 0.0 (9.9.99)",13,10;0
.ResAuto:
		dc.l	$002A           ; VersionLib_SIZEOF
		dc.l	.LibVect
		dc.l	.LibHead
		dc.l	.LibInit
.LibVect:
		dc.w	-1
		dc.w	.LibOpen-.LibVect
		dc.w	.LibClose-.LibVect
		dc.w	.LibExpunge-.LibVect
		dc.w	.LibExtFunc-.LibVect
		dc.w	-1
.LibHead:
		dc.b	%10100110,$08   ; LN_TYPE
		dc.b	9               ; NT_LIBRARY
		dc.b	0
		dc.l	.ResName
		dc.b	$06             ; LIBF_SUMUSED!LIBF_CHANGED
		dc.b	0
		dc.b	%10000000,$18   ; LIB_IDSTRING
		dc.l	.ResVers
		dc.b	%00000000
		dc.b	0
.LibInit:
		movem.l	a6/a2/d2/d0,-(sp)
		movea.l	d0,a2
		move.l	a6,$0022(a2)    ; vl_SysBase
		move.l	a0,$0026(a2)    ; vl_SegList
		lea	$0014+4(a2),a2  ; LIB_VERSION
		move.w	$0022(a6),-(a2) ; SoftVer
		move.w	$0014(a6),-(a2) ; LIB_VERSION
		lea	.WTName(pc),a1
		jsr	-$0060(a6)      ; _LVOFindResident
		tst.l	d0
		beq.s	.nowb
		movea.l	d0,a0
		moveq	#0,d0
		moveq	#10,d2
		move.l	$0012(a0),d1    ; RT_IDSTRING
		beq.s	.tver
		movea.l	d1,a1
.fdot:
		move.b	(a1)+,d1
		beq.s	.tver
		cmpi.b	#$002E,d1       ; '.'
		bne.s	.fdot
.trev:
		moveq	#0,d1
		move.b	(a1)+,d1
		subi.w	#$0030,d1       ; '0'
		bmi.s	.tver
		cmp.w	d2,d1
		bhs.s	.tver
		mulu.w	d2,d0
		add.w	d1,d0
		bra.s	.trev
.tver:
		move.b	$000B(a0),d2    ; RT_VERSION
		swap	d2
		move.w	d0,d2
.setv:
		move.l	d2,(a2)
.nowb:
		movem.l	(sp)+,d0/d2/a2/a6
		rts
.LibOpen:
		move.l	a6,d0
		movem.l	a6/a2/d2/d0,-(sp)
		addq.w	#1,$0020(a6)    ; LIB_OPENCNT
		bclr	#3,$000E(a6)    ; LIBB_DELEXP,LIB_FLAGS
		lea	$0014(a6),a2    ; LIB_VERSION
		movea.l	$0022(a6),a6    ; vl_SysBase
		lea	$017A(a6),a0    ; LibList
		lea	.WLName(pc),a1
		jsr	-$0114(a6)      ; _LVOFindName
		tst.l	d0
		beq.s	.nowb
		movea.l	d0,a0
		move.l	$0014(a0),d2    ; LIB_VERSION
		bra.s	.setv
.LibClose:
		subq.w	#1,$0020(a6)    ; LIB_OPENCNT
		bne.s	.LibExtFunc
		btst	#3,$000E(a6)    ; LIBB_DELEXP,LIB_FLAGS
		beq.s	.LibExtFunc
.LibExpunge:
		tst.w	$0020(a6)       ; LIB_OPENCNT
		beq.s	.LibFree
		bset	#3,$000E(a6)    ; LIBB_DELEXP,LIB_FLAGS
.LibExtFunc:
		moveq	#0,d0
		rts
.LibFree	move.l	$0026(a6),-(sp) ; vl_SegList
		move.l	a6,-(sp)
		movea.l	(sp),a1
		movea.l	$0022(a6),a6    ; vl_SysBase
		jsr	-$00FC(a6)      ; _LVORemove
		moveq	#0,d0
		moveq	#0,d1
		movea.l	(sp),a1
		move.w	$0010(a1),d0    ; LIB_NEGSIZE
		move.w	$0012(a1),d1    ; LIB_POSSIZE
		suba.l	d0,a1
		add.l	d1,d0
		jsr	-$00D2(a6)      ; _LVOFreeMem
		movea.l	(sp)+,a6
		move.l	(sp)+,d0
		rts
.WTName:
		dc.b	"workbench.task",0
.WLName:
		dc.b	"workbench.library",0
	align	2
.ResEnd:
