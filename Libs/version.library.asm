; vasmm68k_mot[_<HOST>] -Fhunkexe -kick1hunks -nosym -o version.library version.library.asm
;
; 	The LIB_VERSION/LIB_REVISION of Libs/version.library
; 	is used by the Version tool and the Workbench About
; 	requester to display the Workbench version string.
;
VersionLibrary:
		moveq	#-1,d0
		rts
.resTag:
		dc.w	$4AFC           ; RT_MATCHWORD = RTC_MATCHWORD
		dc.l	.resTag         ; RT_MATCHTAG
		dc.l	.resEnd         ; RT_ENDSKIP
		dc.b	$80             ; RT_FLAGS = RTF_AUTOINIT
		dc.b	0               ; RT_VERSION
		dc.b	9               ; RT_TYPE = NT_LIBRARY
		dc.b	0               ; RT_PRI
		dc.l	.resName        ; RT_NAME
		dc.l	.resIdString    ; RT_IDSTRING
		dc.l	.resAuto        ; RT_INIT
.resName:
		dc.b	"version.library",0
.resIdString:
		dc.b	"version 0.0 (9.9.99) HelloAmi",13,10,0
.wbtName:
		dc.b	"workbench.task",0
.wblName:
		dc.b	"workbench.library";0
	align	1
.resAuto:
		dc.l	$002A           ; VersionLib_SIZEOF
		dc.l	.libFunc
		dc.l	.libData
		dc.l	.LibInit
.libFunc:
		dc.w	-1
		dc.w	.LibOpen-.libFunc
		dc.w	.LibClose-.libFunc
		dc.w	.LibExpunge-.libFunc
		dc.w	.LibExtFunc-.libFunc
		dc.w	-1
.libData:
		dc.b	%10100110,$08   ; LN_TYPE/LN_PRI/LN_NAME/LIB_FLAGS
		dc.b	9               ; NT_LIBRARY
		dc.b	0
		dc.l	.resName
		dc.b	$02!$04         ; LIBF_SUMUSED!LIBF_CHANGED
	align	1
		dc.b	%10000000,$18   ; LIB_IDSTRING
		dc.l	.resIdString
		dc.b	%00000000
	align	1
;
; REG(D0) struct Library *library
; LibInit(
; 	REG(D0) struct Library *libBase,
; 	REG(A0) BPTR            segList),
; REG(A6) struct ExecBase *sysBase
;
.LibInit:
		movem.l	d0/d2/a2/a6,-(sp)
		movea.l	d0,a2
		move.l	a6,$0022(a2)    ; vl_SysBase
		move.l	a0,$0026(a2)    ; vl_SegList
		; Kickstart version
		lea	$0014+4(a2),a2  ; LIB_VERSION
		move.w	$0022(a6),-(a2) ; SoftVer (0 in 1.x ROMs)
		move.w	$0014(a6),-(a2) ; LIB_VERSION
		; WB task (1.x), revision from IdString (after first dot)
		lea	.wbtName(pc),a1
		jsr	-$0060(a6)      ; _LVOFindResident
		tst.l	d0
		beq.b	.nowb
		movea.l	d0,a0
		moveq	#0,d0
		moveq	#10,d2
		move.l	$0012(a0),d1    ; RT_IDSTRING
		beq.b	.tver
		movea.l	d1,a1
.fdot:
		move.b	(a1)+,d1
		beq.b	.tver
		cmpi.b	#$002E,d1       ; '.'
		bne.b	.fdot
.trev:
		moveq	#0,d1
		move.b	(a1)+,d1
		subi.w	#$0030,d1       ; '0'
		bmi.b	.tver
		cmp.w	d2,d1
		bhs.b	.tver
		mulu.w	d2,d0
		add.w	d1,d0
		bra.b	.trev
.tver:
		move.b	$000B(a0),d2    ; RT_VERSION
		swap	d2
		move.w	d0,d2
.setv:
		move.l	d2,(a2)
.nowb:
		movem.l	(sp)+,d0/d2/a2/a6
		rts
;
; REG(D0) struct Library *library
; LibOpen(VOID),
; REG(A6) struct Library *libBase
;
.LibOpen:
		move.l	a6,d0
		movem.l	d0/d2/a2/a6,-(sp)
		addq.w	#1,$0020(a6)    ; LIB_OPENCNT
		bclr	#3,$000E(a6)    ; LIBB_DELEXP,LIB_FLAGS
		; update version with currently loaded WB library (2.x)
		lea	$0014(a6),a2    ; LIB_VERSION
		movea.l	$0022(a6),a6    ; vl_SysBase
		lea	$017A(a6),a0    ; LibList
		lea	.wblName(pc),a1
		jsr	-$0114(a6)      ; _LVOFindName
		tst.l	d0
		beq.b	.nowb
		movea.l	d0,a0
		move.l	$0014(a0),d2    ; LIB_VERSION
		bra.b	.setv
;
; REG(D0) BPTR segList
; LibClose(VOID),
; REG(A6) struct Library *libBase
;
.LibClose:
		subq.w	#1,$0020(a6)    ; LIB_OPENCNT
		bne.b	.LibNull
		btst	#3,$000E(a6)    ; LIBB_DELEXP,LIB_FLAGS
		beq.b	.LibNull
;
; REG(D0) BPTR segList
; LibExpunge(VOID),
; REG(A6) struct Library *libBase
;
.LibExpunge:
		tst.w	$0020(a6)       ; LIB_OPENCNT
		beq.b	.LibFree
		bset	#3,$000E(a6)    ; LIBB_DELEXP,LIB_FLAGS
;
; REG(D0) APTR null
; LibExtFunc(VOID),
; REG(A6) struct Library *libBase
;
.LibExtFunc:
.LibNull:
		moveq	#0,d0
		rts
.LibFree:
		move.l	$0026(a6),-(sp) ; vl_SegList
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
	align	2
.resEnd:
