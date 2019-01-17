; vasmm68k_mot[_<HOST>] -Fhunkexe -kick1hunks -nosym -o icon.library icon.library.asm
;
;   NAME
;	libs/icon.library
;
;   SYNOPSIS
;	Implementation of a V1.x libs/icon.library replacement to allow
;	creating the Workbench task from V1.x ROMs without the need for
;	the original Workbench disk (which you otherwise must own/buy).
;
;	The main target of this project is to keep the library as small
;	as possible. Therefore, the code is not optimized for speed but
;	size (which makes it sometimes less readable and maintainable).
;
;    NOTES
;	This implementation is not intended to be used with V2+ ROMs
;	(internal struct il, NewDD, and WBObject have been changed).
;	However, due to the low version number and the fact that the
;	library is present in V2+ ROMs, it isn't loaded by V2+ ROMs.
;
IconLibrary:
		moveq	#-1,d0
		rts
.resTag:
		dc.w	$4AFC           ; RT_MATCHWORD = RTC_MATCHWORD
		dc.l	.resTag         ; RT_MATCHTAG
		dc.l	iconEnd         ; RT_ENDSKIP
		dc.b	$80             ; RT_FLAGS = RTF_AUTOINIT
		dc.b	35              ; RT_VERSION
		dc.b	9               ; RT_TYPE = NT_LIBRARY
		dc.b	0               ; RT_PRI
		dc.l	.resName        ; RT_NAME
		dc.l	.resIdString    ; RT_IDSTRING
		dc.l	.resAuto        ; RT_INIT
.resName:
		dc.b	"icon.library",0
		dc.b	"$VER: "
.resIdString:
		dc.b	"icon 35.1 (9.9.99) [HelloAmi]",13,10,0
.dosName:
		dc.b	"dos.library";0
	align	1
.resAuto:
		dc.l	$0032           ; il_Sizeof
		dc.l	.libFunc
		dc.l	.libData
		dc.l	.LibInit
.libFunc:
		dc.w	-1
		; bias 30
		dc.w	.LibOpen-.libFunc               ; -$0006
		dc.w	.LibClose-.libFunc              ; -$000C
		dc.w	.LibExpunge-.libFunc            ; -$0012
		dc.w	.LibExtFunc-.libFunc            ; -$0018
		; private
		dc.w	IGetWBObject-.libFunc           ; -$001E
		dc.w	IPutWBObject-.libFunc           ; -$0024
		dc.w	IGetIcon-.libFunc               ; -$002A
		dc.w	IPutIcon-.libFunc               ; -$0030
		; public
		dc.w	IFreeFreeList-.libFunc          ; -$0036
		; private
		dc.w	IFreeWBObject-.libFunc          ; -$003C
		dc.w	IAllocWBObject-.libFunc         ; -$0042
		; public
		dc.w	IAddFreeList-.libFunc           ; -$0048
		dc.w	IGetDiskObject-.libFunc         ; -$004E
		dc.w	IPutDiskObject-.libFunc         ; -$0054
		dc.w	IFreeDiskObject-.libFunc        ; -$005A
		dc.w	IFindToolType-.libFunc          ; -$0060
		dc.w	IMatchToolValue-.libFunc        ; -$0066
		dc.w	IBumpRevision-.libFunc          ; -$006C
		; version 36
		; private
		dc.w	IFreeAlloc-.libFunc             ; -$0072
		; public
	;	dc.w	IGetDefDiskObject-.libFunc      ; -$0078
	;	dc.w	IPutDefDiskObject-.libFunc      ; -$007E
	;	dc.w	IGetDiskObjectNew-.libFunc      ; -$0084
		; version 37
	;	dc.w	IDeleteDiskObject-.libFunc      ; -$008A
		; reserve 4
	;	dc.w	.LibNull-.libFunc               ; -$0090
	;	dc.w	.LibNull-.libFunc               ; -$0096
	;	dc.w	.LibNull-.libFunc               ; -$009C
	;	dc.w	.LibNull-.libFunc               ; -$00A2
		dc.w	-1
.libData:
		dc.b	%10100110,$08   ; LN_TYPE/LN_PRI/LN_NAME/LIB_FLAGS
		dc.b	9               ; NT_LIBRARY
		dc.b	0
		dc.l	.resName
		dc.b	$02!$04         ; LIBF_SUMUSED!LIBF_CHANGED
	align	1
		dc.b	%10000001,$14   ; LIB_VERSION/LIB_REVISION/LIB_IDSTRING
		dc.w	35,1
		dc.l	.resIdString
	align	1
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
		movem.l	d0-d1/a0-a2,-(sp)
		movea.l	d0,a2
		move.l	a6,$0022(a2)    ; il_SysBase
		move.l	a0,$002E(a2)    ; il_SegList
		lea	.dosName(pc),a1
		jsr	-$0198(a6)      ; _LVOOldOpenLibrary
		move.l	d0,$0026(a2)    ; il_DOSBase
		bne.b	.initRts
		move.l	d0,(sp)         ; (sp),library/*
		exg	a2,a6
		bsr.b	.LibFree
		exg	a6,a2
.initRts:
		movem.l	(sp)+,d0-d1/a0-a2
		rts
;
; REG(D0) struct Library *library
; LibOpen(VOID),
; REG(A6) struct Library *libBase
;
.LibOpen:
		addq.w	#1,$0020(a6)    ; LIB_OPENCNT
		bclr.b	#3,$000E(a6)    ; LIBB_DELEXP,LIB_FLAGS
		move.l	a6,d0
		rts
;
; REG(D0) BPTR segList
; LibClose(VOID),
; REG(A6) struct Library *libBase
;
.LibClose:
		subq.w	#1,$0020(a6)    ; LIB_OPENCNT
		bne.b	.LibNull
		btst.b	#3,$000E(a6)    ; LIBB_DELEXP,LIB_FLAGS
		beq.b	.LibNull
;
; REG(D0) BPTR segList
; LibExpunge(VOID),
; REG(A6) struct Library *libBase
;
.LibExpunge:
		tst.w	$0020(a6)       ; LIB_OPENCNT
		beq.b	.LibFree
		bset.b	#3,$000E(a6)    ; LIBB_DELEXP,LIB_FLAGS
;
; REG(D0) APTR null
; LibExtFunc(VOID),
; REG(A6) struct Library *libBase
;
.LibExtFunc:
.LibNull:
		moveq	#0,d0
		rts
;
; REG(D0) BPTR segList
; LibFree(VOID),
; REG(A6) struct Library *libBase
;
.LibFree:
		movem.l	d0-d1/a0-a1,-(sp)
		move.l	$002E(a6),(sp)  ; il_SegList
		move.l	$0026(a6),d1    ; il_DOSBase
		beq.b	.freeLib
		movea.l	d1,a1
		movea.w	#-$019E,a0      ; _LVOCloseLibrary
		bsr.b	ISysCall
.freeLib:
		movea.l	a6,a1
		movea.w	#-$00FC,a0      ; _LVORemove
		bsr.b	ISysCall
		moveq	#0,d0
		moveq	#0,d1
		move.w	$0010(a6),d0    ; LIB_NEGSIZE
		move.w	$0012(a6),d1    ; LIB_POSSIZE
		movea.l	a6,a1
		suba.l	d0,a1
		add.l	d1,d0
		bsr.b	IFreeMem
		movem.l	(sp)+,d0-d1/a0-a1
		rts

******i icon.library/AllocWBObject *******************************************
*
*   NAME
*	AllocWBObject -- allocate a Workbench object.
*
*   SYNOPSIS
*	object = AllocWBObject().
*	D0
*	struct OldWBObject *AllocWBObject(VOID);
*
*   FUNCTION
*	This routine allocates a Workbench object, and initializes its free
*	list. A subsequent call to FreeWBObject will free all of its memory.
*
*   RESULTS
*	object -- a pointer to the Workbench object
*
******************************************************************************
IAllocWBObject:
		move.l	d1,-(sp)
		moveq	#$00A8/2,d0     ; sizeof OldWBObject
		add.l	d0,d0
		moveq	#$008C/2,d1     ; OldWBObject.wo_FreeList
		add.l	d1,d1
		bsr.b	IAllocObject
		move.l	(sp)+,d1
		rts

;
; REG(D0) APTR object
; IAllocObject(
; 	REG(D0) ULONG byteSize,
; 	REG(D1) ULONG freeList),
; REG(A6) struct il *iconBase
;
; NOTES
; 	preserves all registers (except D0.L/CCR)
;
IAllocObject:
		movem.l	d0-d2/a0-a2,-(sp)
		movea.l	d0,a2
		move.l	d1,d2
		bsr.b	IAllocMemPublicClear
		move.l	d0,(sp)         ; (sp),object/*
		beq.b	.done
		movea.l	d0,a0
		lea	$02(a0,d2.l),a0 ; fl_MemList
		move.l	a0,$0008(a0)    ; LH_TAILPRED
		addq.l	#4,a0           ; LH_TAIL
		move.l	a0,-(a0)
		; WB1 behaviour, see IFreeWBObject/IFreeDiskObject
		subq.l	#2,a0           ; fl_MemList
		movea.l	(sp),a1         ; (sp),object/*
		jsr	-$0048(a6)      ; _LVOAddFreeList
		tst.l	d0
		bne.b	.done
		movea.l	(sp),a1         ; (sp),object/*
		move.l	d0,(sp)         ; (sp),object/*
		move.l	a2,d0
		bsr.b	IFreeMem
.done:
		movem.l	(sp)+,d0-d2/a0-a2
		rts

;
; VOID
; IFreeMem(
; 	REG(A1) APTR  memoryBlock,
; 	REG(D0) ULONG byteSize),
; REG(A6) struct il *iconBase
;
IFreeMem:
		movea.w	#-$00D2,a0      ; _LVOFreeMem
;
; REG(D0) APTR result
; ISysCall(
; 	REG(A0) WORD execLVO),
; REG(A6) struct il *iconBase
;
ISysCall:
		move.l	a6,-(sp)
		movea.l	$0022(a6),a6    ; il_SysBase
		jsr	(a6,a0.w)
		movea.l	(sp)+,a6
		rts

;
; REG(D0) APTR memoryBlock
; IAllocMemPublicClear(
; 	REG(D0) ULONG byteSize),
; REG(A6) struct il *iconBase
;
IAllocMemPublicClear:
		; MEMF_PUBLIC!MEMF_CLEAR
		move.l	#$00010001,d1
;
; REG(D0) APTR memoryBlock
; IAllocMem(
; 	REG(D0) ULONG byteSize,
; 	REG(D1) ULONG attributes),
; REG(A6) struct il *iconBase
;
IAllocMem:
		movea.w	#-$00C6,a0      ; _LVOAllocMem
		bra.b	ISysCall
	;	rts

******* icon.library/GetDiskObject *******************************************
*
*   NAME
*	GetDiskObject -- read in a Workbench disk object from disk.
*
*   SYNOPSIS
*	object = GetDiskObject(name)
*	D0                     A0
*	struct DiskObject *GetDiskObject(STRPTR);
*
*   FUNCTION
*	This routine reads in a Workbench disk object in from disk.
*	The name parameter will have a ".info" postpended to it,
*	and the info file of that name will be read.
*	If the call fails, it will return zero.
*	The reason for the failure may be obtained via IoErr().
*
*	A FreeList structure is allocated just after the DiskObject
*	structure. FreeDiskObject makes use of this to get rid of the
*	memory that was allocated.
*
*   INPUTS
*	name -- name of the object
*
*   RESULTS
*	object -- the Workbench disk object in question
*
*   NOTES
*	Extensions to the original behaviour:
*	- name can be NULL to just allocate a structure (WB2/WB3)
*
******************************************************************************
IGetDiskObject:
		movem.l	d0-d1/a0-a2,-(sp)
		moveq	#$004E+$0010,d0 ; do_SIZEOF+FreeList_SIZEOF
		moveq	#$004E,d1       ; do_SIZEOF
		bsr.b	IAllocObject
		move.l	d0,(sp)         ; (sp),object/*
		beq.b	.done
		; test name for NULL
		move.l	a0,d1
		beq.b	.done
		; else read the icon
		movea.l	d0,a1
		lea	$004E(a1),a2    ; do_SIZEOF
		jsr	-$002A(a6)      ; _LVOGetIcon
		tst.l	d0
		bne.b	.done
		; don't use LVO to free object
		; (might have been overridden)
		movea.l	(sp),a0         ; (sp),object/*
		move.l	d0,(sp)         ; (sp),object/*
		bsr.b	IFreeDiskObject
.done:
		movem.l	(sp)+,d0-d1/a0-a2
		rts

******i icon.library/FreeAlloc ***********************************************
*
*   NAME
*	FreeAlloc -- allocate memory and add it to a free list. (V36)
*
*   SYNOPSIS
*	mem = FreeAlloc(free, len, type)
*	D0              A0    A1   A2
*	APTR FreeAlloc(struct FreeList *, ULONG, ULONG);
*
*   FUNCTION
*	This routine allocates the amount of memory specified and then adds
*	it to the free list. The free list will be extended (if required).
*	If the call fails, it will return zero.
*
*   INPUTS
*	free -- a pointer to a FreeList structure
*	len -- the length of the memory to be recorded
*	type -- the type of memory to be allocated
*
*   RESULTS
*	mem -- a pointer to the newly allocated memory chunk
*
******************************************************************************
IFreeAlloc:
		move.l	d1,-(sp)
		movem.l	d0/a0-a3,-(sp)  ; (sp),mem/free/len/type/*
		move.l	a1,d0
		move.l	a2,d1
		bsr.b	IAllocMem
		move.l	d0,(sp)         ; (sp),mem/*
		beq.b	.done
		movem.l	(sp),d0/a0/a2   ; (sp),mem/free/len/*
		movea.l	d0,a1
		jsr	-$0048(a6)      ; _LVOAddFreeList
		tst.l	d0
		bne.b	.done
		movem.l	(sp),a1/a2/a3   ; (sp),mem/free/len/*
		move.l	d0,(sp)
		move.l	a3,d0
		bsr.b	IFreeMem
.done:
		movem.l	(sp)+,d0/a0-a3
		move.l	(sp)+,d1
		rts

;
; REG(D0) CCR(Z) ULONG numFree
; IReplenishFreeList(
; 	REG(A0) struct FreeList *free),
; REG(A6) struct il *iconBase
;
; NOTES
; 	preserves A0.L/A1.L
;
IReplenishFreeList:
		movem.l	a0-a1,-(sp)     ; (sp),free/*
		move.l	a0,d0
		beq.b	.done
		move.w	(a0),d0         ; (fl_NumFree)
		ext.l	d0
		bgt.b	.done
		moveq	#10*$08+$10,d0  ; 10*ME_SIZE+ML_SIZE
		bsr.b	IAllocMemPublicClear
		movea.l	(sp),a0         ; (sp),free/*
		tst.l	d0
		beq.b	.done
		movea.l	d0,a1
		moveq	#10,d0
		move.w	d0,(a0)+        ; (fl_NumFree)/fl_MemList
		move.w	d0,$000E(a1)    ; ML_NUMENTRIES
		move.l	a6,-(sp)
		movea.l	$0022(a6),a6    ; il_SysBase
		jsr	-$00F6(a6)      ; _LVOAddTail
		movea.l	(sp)+,a6
		moveq	#10,d0
.done:
		movem.l	(sp)+,a0-a1
		rts

******i icon.library/FreeWBObject ********************************************
*
*   NAME
*	FreeWBObject -- free all memory in a Workbench object.
*
*   SYNOPSIS
*	FreeWBObject(object)
*	             A0
*	VOID FreeWBObject(struct OldWBObject *);
*
*   FUNCTION
*	This routine frees all memory in a Workbench object, and the
*	object itself. It is implemented via FreeFreeList().
*
*	AllocWBObject() takes care of all the initialization required
*	to set up the objects free list.
*
*   INPUTS
*	object -- a pointer to a Workbench object
*
******************************************************************************
IFreeWBObject:
		move.l	a0,-(sp)
		beq.b	.done
		lea	$008C(a0),a0    ; OldWBObject.wo_FreeList
		jsr	-$0036(a6)      ; _LVOFreeFreeList
		; no FreeMem(object) here (like WB2/WB3), assumes
		; that object is the first entry in its free list
.done:
		movea.l	(sp)+,a0
		rts

******* icon.library/FreeDiskObject ******************************************
*
*   NAME
*	FreeDiskObject - free all memory in a Workbench disk object.
*
*   SYNOPSIS
*	FreeDiskObject(object)
*	               A0
*	VOID FreeDiskObject(struct DiskObject *);
*
*   FUNCTION
*	This routine frees all memory in a Workbench disk object,
*	and the object itself. It is implemented via FreeFreeList().
*
*	GetDiskObject() takes care of all the initialization required
*	to set up the object's free list. This procedure may ONLY
*	be called on a DiskObject allocated via GetDiskObject().
*
*   INPUTS
*	object -- a pointer to a DiskObject structure
*
******************************************************************************
IFreeDiskObject:
		move.l	a0,-(sp)
		beq.b	.done
		lea	$004E(a0),a0    ; do_SIZEOF
		jsr	-$0036(a6)      ; _LVOFreeFreeList
		; no FreeVec(object) here (like WB2/WB3), assumes
		; that object is the first entry in its free list
.done:
		movea.l	(sp)+,a0
		rts

******* icon.library/AddFreeList *********************************************
*
*   NAME
*	AddFreeList - add memory to a free list.
*
*   SYNOPSIS
*	status = AddFreeList(free, mem, len)
*	D0                   A0    A1   A2
*	BOOL AddFreeList(struct FreeList *, APTR, ULONG);
*
*   FUNCTION
*	This routine adds the specified memory to the free list.
*	The free list will be extended (if required).  If there
*	is not enough memory to complete the call, a null is returned.
*
*	Note that AddFreeList does NOT allocate the requested memory.
*	It only records the memory in the free list.
*
*   INPUTS
*	free -- a pointer to a FreeList structure
*	mem -- the base of the memory to be recorded
*	len -- the length of the memory to be recorded
*
*   RESULTS
*	status -- TRUE if the call succeeded, else FALSE
*
******************************************************************************
IAddFreeList:
		movem.l	d1/a0,-(sp)
		bsr.b	IReplenishFreeList
		beq.b	.done
		subq.l	#1,d0
		move.w	d0,(a0)+        ; (fl_NumFree)/fl_MemList
		lsl.l	#3,d0           ; *ME_SIZE
		movea.l	$0008(a0),a0    ; LH_TAILPRED
		lea	$10(a0,d0.l),a0 ; ML_ME
		move.l	a1,(a0)+        ; (ME_ADDR)
		move.l	a2,(a0)         ; (ME_LENGTH)
		moveq	#1,d0
.done:
		movem.l	(sp)+,d1/a0
		rts

******* icon.library/FreeFreeList ********************************************
*
*   NAME
*	FreeFreeList -- free all memory in a free list.
*
*   SYNOPSIS
*	FreeFreeList(free)
*	             A0
*	VOID FreeFreeList(struct FreeList *);
*
*   FUNCTION
*	This routine frees all memory in a free list, and the free list 
*	itself. It is useful for easily getting rid of all memory in a
*	series of structures. There is a free list in a Workbench object,
*	and this contains all the memory associated with that object.
*
*	A FreeList is a list of MemList structures. See the
*	MemList and MemEntry documentation for more information.
*
*	If the FreeList itself is in the free list, it must be
*	in the first MemList in the FreeList.
*
*   INPUTS
*	free -- a pointer to a FreeList structure
*
******************************************************************************
IFreeFreeList:
		movem.l	d0-d2/a0-a1/a6,-(sp)
		move.l	a0,d2
		beq.b	.done           ; (NULL)
		move.l	$000A(a0),d2    ; fl_MemList+LH_TAILPRED
		beq.b	.done           ; (invalid, NewList missing)
		movea.l	$0022(a6),a6    ; il_SysBase
.loop:
		movea.l	d2,a0
		move.l	$0004(a0),d2    ; LN_PRED
		beq.b	.done
		jsr	-$00E4(a6)      ; _LVOFreeEntry
		bra.b	.loop
.done:
		movem.l	(sp)+,d0-d2/a0-a1/a6
		rts

******i icon.library/GetWBObject *********************************************
*
*   NAME
*	GetWBObject -- read in a Workbench object from disk.
*
*   SYNOPSIS
*	object = GetWBObject(name)
*	D0                   A0
*	struct OldWBObject *GetWBObject(STRPTR);
*
*   FUNCTION
*	This routine reads in a Workbench object in from disk.
*	The name parameter will have a ".info" postpended to it,
*	and the info file of that name will be read.
*	If the call fails, it will return zero.
*	The reason for the failure may be obtained via IoErr().
*
*   INPUTS
*	name -- name of the object
*
*   RESULTS
*	object -- the Workbench object in question
*
******************************************************************************
IGetWBObject:
		movem.l	d1/a0-a3,-(sp)
		link.w	a4,#-$0050      ; (do_SIZEOF+3)&~3
		movea.l	a0,a2
		jsr	-$0042(a6)      ; _LVOAllocWBObject
		move.l	d0,-(sp)
		beq.b	.done
		movea.l	d0,a3
		movea.l	a2,a0
		lea	-$0050(a4),a1
		lea	$008C(a3),a2    ; OldWBObject.wo_FreeList
		jsr	-$002A(a6)      ; _LVOGetIcon
		tst.l	d0
		beq.b	.free
		lea	$0004-$0050(a4),a0      ; do_Gadget
		lea	$0060(a3),a1            ; OldWBObject.wo_Gadget
		moveq	#$002C/4-1,d0           ; gg_SIZEOF
.loop:
		move.l	(a0)+,(a1)+
		dbf	d0,.loop
		move.b	(a0)+,$003D(a3) ; OldWBObject.wo_Type
		addq.l	#1,a0           ; (do_PAD_BYTE)
		move.l	(a0)+,$0048(a3) ; OldWBObject.wo_DefaultTool
		move.l	(a0)+,$005C(a3) ; OldWBObject.wo_ToolTypes
		move.l	(a0)+,$0054(a3) ; OldWBObject.wo_CurrentX
		move.l	(a0)+,$0058(a3) ; OldWBObject.wo_CurrentY
		movea.l	(a0)+,a1        ; (do_DrawerData)
		move.l	(a0)+,$009C(a3) ; OldWBObject.wo_ToolWindow
		move.l	(a0),$00A0(a3)  ; OldWBObject.wo_StackSize
		move.l	a1,$004C(a3)    ; OldWBObject.wo_DrawerData
		beq.b	.done
		move.l	a3,$01A8(a1)    ; OldNewDD.dd_Object
.done:
		move.l	(sp)+,d0
		unlk	a4
		movem.l	(sp)+,d1/a0-a3
		rts
.free:
		movea.l	(sp),a0
		move.l	d0,(sp)
		jsr	-$003C(a6)      ; _LVOFreeWBObject
		bra.b	.done

******i icon.library/GetIcon *************************************************
*
*   NAME
*	GetIcon -- read in a DiskObject structure from disk.
*
*   SYNOPSIS
*	status = GetIcon(name, icon, free)
*	D0               A0    A1    A2
*	BOOL GetIcon(STRPTR, struct DiskObject *, struct FreeList *);
*
*   FUNCTION
*	This routine reads in a DiskObject structure, and its associated
*	information. All memory will be automatically allocated, and stored
*	in the specified FreeList. The file name of the info file will be
*	the name parameter with a ".info" postpended to it.
*	If the call fails, a zero will be returned.
*	The reason for the failure may be obtained via IoErr().
*
*   INPUTS
*	name -- name of the object
*	icon -- a pointer to a DiskObject
*	free -- a pointer to a FreeList
*
*   RESULTS
*	status -- non-zero if the call succeeded
*
*   NOTES
*	Differences to the original behaviour:
*	- only Image (no Border) gadgets are supported (WB2/WB3)
*	- gg_GadgetRender has to be present (NULL breaks 1.x WB)
*
*	As of release V2.0 this function allocates a NewDD structure
*	instead of a OldNewDD structure for the do_DrawerData field.
*
******************************************************************************
IGetIcon:
		movem.l	d1-d5/a0-a5,-(sp)
		movea.l	a1,a3
		movea.l	a2,a4
		move.l	#1005,d2        ; MODE_OLDFILE
		bsr.w	IOpen
		move.l	d0,d4
		beq.b	.nope
		; read disk object
		move.l	a3,d2
		moveq	#$004E,d3       ; do_SIZEOF
		bsr.w	IRead
		bne.b	.eowt
		cmpi.l	#$E3100001,(a3)+        ; WB_DISKMAGIC/WB_DISKVERSION
		bne.b	.eowt
		btst.b	#2,$000C+1(a3)  ; log2(GFLG_GADGIMAGE),gg_Flags
		beq.b	.eowt
		tst.l	$0012(a3)       ; gg_GadgetRender
		bne.b	.dodd
.eowt:
		bsr.b	ISetIoErrObjectWrongType
.fail:
		moveq	#0,d5           ; FALSE
.done:
		bsr.w	IClose
		move.l	d5,d0
.nope:
		movem.l	(sp)+,d1-d5/a0-a5
		rts
.dodd:
		moveq	#1,d5           ; TRUE
		; read drawer data
		lea	$0042-$0004(a3),a5      ; do_DrawerData-do_Gadget
		tst.l	(a5)
		beq.b	.ggim
		moveq	#$0038,d3       ; OldDrawerData_SIZEOF
		movea.w	#$01BE,a1       ; sizeof OldNewDD (NewDD $01D8)
		movea.l	#$00010001,a2   ; MEMF_PUBLIC!MEMF_CLEAR (WB1 chip)
		bsr.w	IReadFreePart
		beq.b	.fail
		lea	$01AC(a5),a5    ; OldNewDD.dd_Children (NewDD $01B2)
		move.l	a5,$0008(a5)    ; LH_TAILPRED
		addq.l	#4,a5	        ; LH_TAIL
		move.l	a5,-(a5)
.ggim:
		; read gadget images
		lea	$0012(a3),a5    ; gg_GadgetRender
		bsr.b	IReadImage
		beq.b	.fail
		addq.l	#4,a5           ; gg_SelectRender-gg_GadgetRender
		bsr.b	IReadImage
		beq.b	.fail
		; skip gadget text
		clr.l	$001A(a3)       ; gg_GadgetText
		; read default tool
		lea	$0032-$0004(a3),a5      ; do_DefaultTool-do_Gadget
		bsr.w	IReadString
		beq.b	.fail
		; read tool types
		addq.l	#4,a5           ; do_ToolTypes-do_DefaultTool
		bsr.w	IReadStrings
		beq.b	.fail
		; read tool window
		lea	$0046-$0004(a3),a5      ; do_ToolWindow-do_Gadget
		bsr.b	IReadString
		beq.b	.fail
		; final cleanup
		clr.l	(a3)            ; (gg_NextGadget)
		clr.l	$0028(a3)       ; gg_UserData
		bra.b	.done

;
; REG(D0) LONG oldCode
; ISetIoErrObjectWrongType(VOID),
; REG(A6) struct il *iconBase
;
ISetIoErrObjectWrongType:
		moveq	#212/2,d0       ; ERROR_OBJECT_WRONG_TYPE
		add.l	d0,d0
;
; REG(D0) LONG oldCode
; ISetIoErr(
; 	REG(D0) LONG code),
; REG(A6) struct il *iconBase
;
ISetIoErr:
		move.l	d0,d1
		moveq	#0,d0
		movea.l	$0022(a6),a0    ; il_SysBase
		movea.l $0114(a0),a0    ; ThisTask
		cmpi.b	#13,$0008(a0)   ; NT_PROCESS,LN_TYPE
		bne.b	.done
		move.l	$0094(a0),d0    ; pr_Result2
		move.l	d1,$0094(a0)    ; pr_Result2
.done:
		rts

;
; REG(D0) CCR(Z) BOOL status
; IReadImage(VOID),
; REG(D4) BPTR             file,
; REG(A4) struct FreeList *free,
; REG(A5) struct Image   **image,
; REG(A6) struct il       *iconBase
;
; NOTES:
; 	registers D3/A2 are NOT preserved
;
IReadImage:
		move.l	a5,-(sp)
		tst.l	(a5)
		beq.b	IReadRefTrue
		; read Image struct
		moveq	#$0014,d3       ; ig_SIZEOF
		movea.w	#$0001,a2       ; MEMF_PUBLIC
		bsr.w	IReadFree
		beq.b	IReadRefDone
		; read image planes
		bsr.w	IProcessImage
		ble.b	IReadRefEowt
		movea.w	#$0003,a2       ; MEMF_PUBLIC!MEMF_CHIP
		bsr.w	IReadFree
		beq.b	IReadRefFail
IReadRefTrue:
		moveq	#1,d0           ; TRUE
IReadRefDone:
		movea.l	(sp)+,a5
		rts
IReadRefEowt:
		bsr.b	ISetIoErrObjectWrongType
IReadRefFail:
		moveq	#0,d0           ; FALSE/NULL
		movea.l	(sp),a5
		move.l	d0,(a5)
		bra.b	IReadRefDone

;
; REG(D3) CCR(N,Z) LONG value
; IReadLong(VOID),
; REG(D4) BPTR             file,
; REG(A6) struct il       *iconBase
;
; NOTES:
; 	registers D2-D3 are NOT preserved
;
IReadLong:
		moveq	#4,d3
		move.l	d3,-(sp)
		move.l	sp,d2
		bsr.b	IRead
		beq.b	.done
		clr.l	(sp)
.done:
		move.l	(sp)+,d3
		rts

;
; REG(D0) CCR(Z) BOOL status
; IReadString(VOID),
; REG(D4) BPTR             file,
; REG(A4) struct FreeList *free,
; REG(A5) STRPTR          *str,
; REG(A6) struct il       *iconBase
;
; NOTES:
; 	registers D2-D3/A2 are NOT preserved
;
IReadString:
		move.l	a5,-(sp)
		tst.l	(a5)
		beq.b	IReadRefTrue
		; read length
		bsr.b	IReadLong
		ble.b	IReadRefEowt
		; read string
		movea.w	#$0001,a2       ; MEMF_PUBLIC
		bsr.w	IReadFree
		beq.b	IReadRefDone
		; force EOS (custom extension)
		clr.b	-1(a5,d3.l)
		bra.b	IReadRefTrue

;
; REG(D0) CCR(Z) BOOL status
; IReadStrings(VOID),
; REG(D4) BPTR             file,
; REG(A4) struct FreeList *free,
; REG(A5) STRPTR         **strs,
; REG(A6) struct il       *iconBase
;
; NOTES:
; 	registers D2-D3/A2 are NOT preserved
;
IReadStrings:
		move.l	a5,-(sp)
		tst.l	(a5)
		beq.b	IReadRefTrue
		; read table size
		bsr.b	IReadLong
		; test table size (custom extension)
		asr.l	#2,d3
		asl.l	#2,d3
		ble.b	IReadRefEowt
		; alloc table mem
		movea.l	a4,a0
		movea.l	d3,a1
		movea.w	#$0001,a2       ; MEMF_PUBLIC
		jsr	-$0072(a6)      ; _LVOFreeAlloc
		move.l	d0,(a5)
		beq.b	IReadRefFail
		; fill table (BOOL*,NULL)
		movea.l	d0,a5
		bra.b	.null
.bool:
		move.l	d0,(a5)+
.null:
		subq.l	#4,d3
		bne.b	.bool
		clr.l	(a5)
		; read strings
		movea.l	d0,a5
.read:
		tst.l	(a5)
		beq.b	IReadRefTrue
		bsr.b	IReadString
		beq.b	IReadRefFail
		addq.l	#4,a5
		bra.b	.read

;
; VOID
; IClose(VOID),
; REG(D4) BPTR       file,
; REG(A6) struct il *iconBase
;
IClose:
		move.w	#-$0084,d0      ; _LVOIoErr
		bsr.b	IDosCall
		move.l	d0,-(sp)
		move.l	d4,d1
		beq.b	.done
		move.w	#-$0024,d0      ; _LVOClose
		bsr.b	IDosCall
.done:
		move.l	(sp)+,d0
		bra.w	ISetIoErr
	;	rts

;
; REG(D0) CCR(Z) BOOL failure
; IRead(
; 	REG(D2) APTR buffer,
; 	REG(D3) LONG length),
; REG(D4) BPTR       file,
; REG(A6) struct il *iconBase
;
IRead:
		move.l	d4,d1
		move.w	#-$002A,d0      ; _LVORead
		bsr.b	IDosCall
		sub.l	d3,d0
		rts

;
; REG(D3) CCR(Z) LONG  byteSize,
; REG(A5)        APTR *imageData
; IProcessImage(
; 	REG(A5) struct Image *image)
;
; NOTES
; 	byteSize 0 for negative or zero width, height, or depth
;
IProcessImage:
		; reset relative offsets (WB2/WB3)
		clr.l	(a5)+           ; (ig_LeftEdge/ig_TopEdge)
		; RASSIZE(width, height) * depth
		move.w	(a5)+,d3        ; (ig_Width)
		ext.l	d3
		ble.b	.fail
		moveq	#16-1,d0        ; used words
		add.l	d0,d3
		lsr.l	#4,d3           ; word count
		move.w	(a5)+,d1        ; (ig_Height)
		ext.l	d1
		ble.b	.fail
		move.w	(a5)+,d0        ; (ig_Depth)/ig_ImageData
		ext.l	d0
		ble.b	.fail
		; multiply with depth first (up to 32767x32767x16)
		mulu.w	d0,d3
		swap	d3
		tst.w	d3
		bne.b	.fail
		swap	d3
		mulu.w	d1,d3
		; save result pointer to ig_ImageData
		move.l	a5,-(sp)
		addq.l	#4,a5           ; ig_PlanePick-ig_ImageData
		; reset image plane masks (WB2/WB3)
		moveq	#1,d1
		lsl.l	d0,d1
		subq.l	#1,d1
		move.b	d1,(a5)+        ; (ig_PlanePick)
		clr.b	(a5)+           ; (ig_PlaneOnOff)
		; reset next image pointer
		clr.l	(a5)            ; (ig_NextImage)
		movea.l	(sp)+,a5
.done:
		lsl.l	#1,d3           ; byte count
		rts
.fail:
		moveq	#0,d3
		bra.b	.done

;
; REG(D0) APTR result
; IDosCall(
; 	REG(D0) WORD dosLVO),
; REG(A6) struct il *iconBase
;
IDosCall:
		move.l	a6,-(sp)
		movea.l	$0026(a6),a6    ; il_DOSBase
		jsr	(a6,d0.w)
		movea.l	(sp)+,a6
		rts

;
; REG(D0,A5) CCR(Z) APTR memoryBlock
; IReadFree(
; 	REG(D3) LONG  readSize,
; 	REG(A2) ULONG attributes,
; 	REG(A5) APTR *memoryRef),
; REG(D4) BPTR             file,
; REG(A4) struct FreeList *free,
; REG(A6) struct il       *iconBase
;
IReadFree:
		movea.l	d3,a1
;
; REG(D0,A5) CCR(Z) APTR memoryBlock
; IReadFree(
; 	REG(D3) LONG  readSize,
; 	REG(A1) ULONG byteSize,
; 	REG(A2) ULONG attributes,
; 	REG(A5) APTR *memoryRef),
; REG(D4) BPTR             file,
; REG(A4) struct FreeList *free,
; REG(A6) struct il       *iconBase
;
IReadFreePart:
		movea.l	a4,a0
		jsr	-$0072(a6)      ; _LVOFreeAlloc
		move.l	d0,(a5)
		beq.b	.done
		move.l	d0,d2
		bsr.b	IRead
		beq.b	.done
		clr.l	(a5)
.done:
		move.l	(a5),d0
		movea.l	d0,a5
		rts

;
; REG(D0) BPTR file
; IOpen(
; 	REG(A0) STRPTR name,
; 	REG(D2) LONG   accessMode),
; REG(A6) struct il *iconBase
;
IOpen:
		move.w	#-$001E,d0      ; _LVOOpen
;
; REG(D0) APTR result
; IIconDosCall(
; 	REG(D0) WORD   dosLVO,
; 	REG(A0) STRPTR name),
; REG(A6) struct il *iconBase
;
; NOTES
; 	name + ".info" will be passed to the DOS function in D1
; 	everything else but D0/A5 can be passed to the function
;
IIconDosCall:
		; name + ".info" on the stack -- note that the
		; name will be truncated after 254 characters,
		; but since AmigaDOS 1.x uses BSTR everywhere,
		; it is not expected to introduce new problems
		; (the original 1.x libraries don't even check
		; the length and just copy it into the stack).
		link.w	a5,#-260
		move.l	sp,d1
		movem.l	d0/a0/a2,-(sp)
		movea.l	a0,a2
		movea.l	d1,a0
		moveq	#(260-5-1)/2,d0
		add.l	d0,d0
		bsr.w	IStrCopyN
		lea	.info(pc),a2
	;	moveq	#5,d0
		bsr.w	IStrCopyN
		movem.l	(sp)+,d0/a0/a2
		bsr.b	IDosCall
		unlk	a5
		rts
.info:
		dc.b	".info",0
	align	1

;
; REG(D0) CCR(Z) BOOL failure
; IWriteLong(
; 	REG(D0) LONG value),
; REG(D4) BPTR             file,
; REG(A6) struct il       *iconBase
;
; NOTES:
; 	registers D2-D3 are NOT preserved
;
IWriteLong:
		move.l	d0,-(sp)
		move.l	sp,d2
		moveq	#4,d3
		bsr.b	IWrite
		addq.l	#4,sp
		rts

;
; REG(D0) CCR(Z) BOOL failure
; IWrite(
; 	REG(D2) APTR buffer,
; 	REG(D3) LONG length),
; REG(D4) BPTR       file,
; REG(A6) struct il *iconBase
;
IWrite:
		move.l	d4,d1
		move.w	#-$0030,d0      ; _LVOWrite
		bsr.b	IDosCall
		sub.l	d3,d0
		rts

;
; REG(D0) CCR(Z) BOOL failure
; IWriteString(VOID),
; REG(D4) BPTR             file,
; REG(A2) STRPTR           str,
; REG(A6) struct il       *iconBase
;
; NOTES:
; 	registers D2-D3 are NOT preserved
;
IWriteString:
		move.l	a2,d0
		move.l	d0,-(sp)
		beq.b	.done
		movea.l	d0,a1
		bsr.w	IStrLen
		addq.l	#1,d0
		move.l	d0,(sp)
		bsr.b	IWriteLong
		bne.b	.done
		move.l	a2,d2
		move.l	(sp),d3
		bsr.b	IWrite
.done:
		addq.l	#4,sp
		rts

;
; REG(D0) CCR(Z) BOOL failure
; IWriteImage(
; 	REG(A2) struct Image *image),
; REG(D4) BPTR          file,
; REG(A6) struct il    *iconBase
;
; NOTES:
; 	registers D2-D3/A2 are NOT preserved
;
IWriteImage:
		
		movem.l	a3/a5,-(sp)
		link.w	a4,#-$0014      ; (ig_SIZEOF+3)&~3
		move.l	a2,d0
		beq.b	.done
		; write Image struct
		movea.l	sp,a5
		moveq	#$0014/4-1,d0   ; ig_SIZEOF
.loop:
		move.l	(a2)+,(a5)+
		dbf	d0,.loop
		movea.l	sp,a5
		bsr.w	IProcessImage
		movea.l	d3,a3
		ble.b	.eowt
		move.l	sp,d2
		moveq	#$0014,d3       ; ig_SIZEOF
		bsr.b	IWrite
		bne.b	.done
		; write image planes
		move.l	(a5),d2
		move.l	a3,d3
		bsr.b	IWrite
		beq.b	.done
.eowt:
		bsr.w	ISetIoErrObjectWrongType
		moveq	#-1,d0
.done:
		unlk	a4
		movem.l	(sp)+,a3/a5
		rts

******* icon.library/PutDiskObject *******************************************
*
*   NAME
*	PutDiskObject -- write out a DiskObject to disk.
*
*   SYNOPSIS
*	status = PutDiskObject(name, object)
*	D0                     A0    A1
*	BOOL PutDiskObject(STRPTR, struct DiskObject *);
*
*   FUNCTION
*	This routine writes out a DiskObject structure, and its associated
*	information. The file name of the info file will be the name
*	parameter with a ".info" postpended to it.
*	If the call fails, a zero will be returned.
*	The reason for the failure may be obtained via IoErr().
*
*   INPUTS
*	name -- name of the object
*	object -- a pointer to a DiskObject
*
*   RESULTS
*	status -- TRUE if the call succeeded, else FALSE
*
*   NOTES
*	In V1.x releases of the icon.library this function is identical
*	to PutIcon(). As of release V2.0, PutDiskObject (if successful)
*	notifies the Workbench that an icon has been created/modified.
*
******************************************************************************
IPutDiskObject:

******i icon.library/PutIcon *************************************************
*
*   NAME
*	PutIcon -- write out a DiskObject to disk.
*
*   SYNOPSIS
*	status = PutIcon(name, icon)
*	D0               A0    A1
*	BOOL PutIcon(STRPTR, struct DiskObject *);
*
*   FUNCTION
*	This routine writes out a DiskObject structure, and its associated
*	information. The file name of the info file will be the name
*	parameter with a ".info" postpended to it.
*	If the call fails, a zero will be returned.
*	The reason for the failure may be obtained via IoErr().
*
*   INPUTS
*	name -- name of the object
*	icon -- a pointer to a DiskObject
*
*   RESULTS
*	status -- TRUE if the call succeeded else FALSE
*
*   NOTES
*	Extensions to the original behaviour:
*	- remove E attribute on success or delete file on failure (WB2/WB3)
*
******************************************************************************
IPutIcon:
		movem.l	d1-d6/a0-a5,-(sp)
		moveq	#0,d4
		movea.l	a1,a3
		movea.l	a0,a5
		move.l	$0004+$0016(a3),d6      ; do_Gadget+gg_SelectRender
		move.w	$0004+$000C(a3),d2      ; do_Gadget+gg_Flags
		btst.l	#2,d2           ; log2(GFLG_GADGIMAGE)
		beq.w	.eowt
		moveq	#$0003,d1       ; GFLG_GADGHIGHBITS
		and.l	d1,d2
		subq.l	#$0001,d2       ; GFLG_GADGBACKFILL
		bne.b	.open
		move.l	d2,$0004+$0016(a3)      ; do_Gadget+gg_SelectRender
.open:
		move.l	#1006,d2        ; MODE_NEWFILE
		bsr.w	IOpen
		move.l	d0,d4
		beq.b	.fail
		; write disk object
		move.l	a3,d2
		moveq	#$004E,d3       ; do_SIZEOF
		bsr.w	IWrite
		bne.b	.fail
		; write drawer data
		move.l	$0042(a3),d2    ; do_DrawerData
		beq.b	.ggim
		moveq	#$0038,d3       ; OldDrawerData_SIZEOF
		bsr.w	IWrite
		bne.b	.fail
.ggim:
		; write gadget images
		movea.l	$0004+$0012(a3),a2      ; do_Gadget+gg_GadgetRender
		bsr.w	IWriteImage
		bne.b	.fail
		movea.l	$0004+$0016(a3),a2      ; do_Gadget+gg_SelectRender
		bsr.w	IWriteImage
		bne.b	.fail
		; write default tool
		movea.l	$0032(a3),a2    ; do_DefaultTool
		bsr.w	IWriteString
		bne.b	.fail
		; write tool types
		move.l	$0036(a3),d0    ; do_ToolTypes
		beq.b	.dotw
		movea.l	d0,a2
		moveq	#0,d0
.ttcn:
		addq.l	#4,d0
		tst.l	(a2)+
		bne.b	.ttcn
		bsr.w	IWriteLong
		bne.b	.fail
		movea.l	$0036(a3),a4    ; do_ToolTypes
.ttws:
		move.l	(a4)+,d0
		beq.b	.dotw
		movea.l	d0,a2
		bsr.w	IWriteString
		bne.b	.fail
		bra.b	.ttws
.dotw:
		; write tool window
		movea.l	$0046(a3),a2    ; do_ToolWindow
		bsr.w	IWriteString
		bne.b	.fail
		moveq	#1,d5           ; TRUE
		bra.b	.done
.eowt:
		bsr.w	ISetIoErrObjectWrongType
.fail:
		moveq	#0,d5           ; FALSE
.done:
		move.l	d6,$0004+$0016(a3)      ; do_Gadget+gg_SelectRender
		bsr.w	IClose
		; status ? SetProtection : DeleteFile (WB2/WB3)
		movea.l	a5,a0
		moveq	#1<<1,d2        ; FIBF_EXECUTE
		move.l	d5,d0
		beq.b	.fdel
		move.w	#$0048-$00BA,d0 ; _LVOSetProtection-_LVODeleteFile
.fdel:
		addi.w	#-$0048,d0      ; _LVODeleteFile
		bsr.w	IIconDosCall
		move.l	d5,d0
		movem.l	(sp)+,d1-d6/a0-a5
		rts

******i icon.library/PutWBObject *********************************************
*
*   NAME
*	PutWBObject -- write out a Workbench object to disk.
*
*   SYNOPSIS
*	status = PutWBObject(name, object)
*	D0                   A0    A1
*	BOOL PutWBObject(STRPTR, struct OldWBObject *);
*
*   FUNCTION
*	This routine writes a Workbench object out to disk.  The name
*	parameter will have a ".info" postpended to it, and that file
*	name will have the disk-resident information written into it.
*	If the call fails, it will return a zero.
*	The reason for the failure may be obtained via IoErr().
*
*   INPUTS
*	name -- name of the object
*	object -- the Workbench object to be written out
*
*   RESULTS
*	status -- TRUE if call succeeded, else FALSE
*
******************************************************************************
IPutWBObject:
		movem.l	d1/a0-a3,-(sp)
		link.w	a4,#-$0050      ; (do_SIZEOF+3)&~3
		movea.l	sp,a3
		move.l	#$E3100001,(a3)+        ; WB_DISKMAGIC/WB_DISKVERSION
		lea	$0060(a1),a2            ; OldWBObject.wo_Gadget
		moveq	#$002C/4-1,d0           ; gg_SIZEOF
.loop:
		move.l	(a2)+,(a3)+
		dbf	d0,.loop
		move.b	$003D(a1),(a3)+ ; OldWBObject.wo_Type
		clr.b	(a3)+           ; (do_PAD_BYTE)
		move.l	$0048(a1),(a3)+ ; OldWBObject.wo_DefaultTool
		move.l	$005C(a1),(a3)+ ; OldWBObject.wo_ToolTypes
		move.l	$0054(a1),(a3)+ ; OldWBObject.wo_CurrentX
		move.l	$0058(a1),(a3)+ ; OldWBObject.wo_CurrentY
		move.l	$004C(a1),(a3)+ ; OldWBObject.wo_DrawerData
		move.l	$009C(a1),(a3)+ ; OldWBObject.wo_ToolWindow
		move.l	$00A0(a1),(a3)  ; OldWBObject.wo_StackSize
		movea.l	sp,a1
		jsr	-$0030(a6)      ; _LVOPutIcon
		unlk	a4
		movem.l	(sp)+,d1/a0-a3
		rts

;
; REG(D0) CCR(Z) ULONG len
; IStrLen(VOID),
; REG(A1) STRPTR str
;
; NOTES
; 	preserves A0.L/A1.L but not D0.L/D1.L/CCR
; 	str pointer might be 0 (returned len = 0)
;
IStrLen:
		moveq	#0,d1
;
; REG(D0) CCR(Z) ULONG len
; IStrLenC(VOID),
; REG(D1) UBYTE  chr,
; REG(A1) STRPTR str
;
; NOTES
; 	preserves all registers (except D0.L/CCR)
; 	str pointer might be 0 (returned len = 0)
;
IStrLenC:
		move.l	a1,d0
		beq.b	.done
.loop:
		cmp.b	(a1),d1
		beq.b	.clen
		tst.b	(a1)+
		bne.b	.loop
		subq.l	#1,a1
.clen:
		exg	a1,d0
		sub.l	a1,d0
.done:
		rts

******* icon.library/FindToolType ********************************************
*
*   NAME
*	FindToolType -- find the value of a ToolType variable.
*
*   SYNOPSIS
*	value = FindToolType(toolTypeArray, typeName)
*	D0                   A0             A1
*	STRPTR FindToolType(STRPTR *, STRPTR);
*
*   FUNCTION
*	This function searches a tool type array for a given entry,
*	and returns a pointer to that entry. This is useful for
*	finding standard tool type variables. The returned
*	value is not a new copy of the string but is only
*	a pointer to the part of the string after typeName.
*
*   INPUTS
*	toolTypeArray -- an array of strings
*	typeName -- the name of the tooltype entry
*
*   RESULTS
*	value -- a pointer to a string that is the value bound to typeName,
*	         or NULL if typeName is not in the toolTypeArray
*
*   NOTES
*	Extensions to the original behaviour:
*	- case-insensitive string comparison (WB2/WB3)
*
******************************************************************************
IFindToolType:
		movem.l	d2/a2-a3,-(sp)
		; test for typeArray NULL pointer
		move.l	a0,d0
		beq.b	.done
		; get name length and use as str2
		bsr.b	IStrLen
		move.l	d0,d2
		movea.l	a1,a2
		lea	IUpper(pc),a3
		; test all type array "=\0" names
		moveq	#$3D,d1         ; EQUALS SIGN
.loop:
		; get next entry and test for end
		move.l	(a0)+,d0
		beq.b	.done
		movea.l	d0,a1
		; get name length and test length
		bsr.b	IStrLenC
		cmp.l	d2,d0
		bne.b	.loop
		; compare and test for full match
		bsr.b	IStrMatchN
		cmp.l	d2,d0
		bne.b	.loop
		; set advanced str1 as the result
		move.l	a1,d0
		; skip over separator, if present
		cmp.b	(a1),d1
		bne.b	.done
		addq.l	#1,d0
.done:
		movem.l	(sp)+,d2/a2-a3
		rts

******* icon.library/MatchToolValue ******************************************
*
*   NAME
*	MatchToolValue -- check a tool type variable for a particular value.
*
*   SYNOPSIS
*	result = MatchToolValue(typeString, value)
*	D0                      A0          A1
*	BOOL MatchToolValue(STRPTR, STRPTR);
*
*   FUNCTION
*	MatchToolValue is useful for parsing a tool type value for a known
*	value. It knows how to parse the syntax for a tool type value
*	(in particular, it knows that '|' separates alternate values).
*
*   INPUTS
*	typeString -- a ToolType value (as returned by FindToolType)
*	value -- you are interested if value appears in typeString
*
*   RESULTS
*	result -- TRUE if the value was in typeString, else FALSE.
*
*   NOTES
*	Extensions to the original behaviour:
*	- case-insensitive string comparison (WB2/WB3)
*
******************************************************************************
IMatchToolValue:
		movem.l	d2/a2-a3,-(sp)
		; test for typeString NULL pointer
		move.l	a0,d0
		beq.b	.done
		; get value length and use as str2
		bsr.b	IStrLen
		move.l	d0,d2
		movea.l	a1,a2
		lea	IUpper(pc),a3
		; test all typeString "|\0" tokens
		movea.l	a0,a1
		moveq	#$7C,d1         ; VERTICAL LINE
.loop:
		; get token length and test length
		bsr.b	IStrLenC
		cmp.l	d2,d0
		bne.b	.next
		bsr.b	IStrMatchN
		; calc mismatch length (0 = match)
		sub.l	d2,d0
		neg.l	d0
		bne.b	.next
		moveq	#1,d0
		bra.b	.done
.next:
		; skip over string/mismatch length
		adda.l	d0,a1
		; skip over previous end separator
		cmp.b	(a1)+,d1
		beq.b	.loop
		moveq	#0,d0
.done:
		movem.l	(sp)+,d2/a2-a3
		rts

;
; REG(D1) UBYTE chr
; IUpperBump(
; 	REG(D1) UBYTE chr)
;
IUpperBump:
		cmpi.b	#$5F,d1         ; LOW LINE
		bne.b	IUpper
		move.b	#$20,d1         ; SPACE
;
; REG(D1) UBYTE chr
; IUpper(
; 	REG(D1) UBYTE chr)
;
; NOTES
; 	preserves all registers (except D1.B/CCR)
; 	full ISO 8859-1 (with Latin-1 Supplement)
;
IUpper:
		cmpi.b	#$61,d1         ; LATIN SMALL LETTER A
		blo.b	.done
		cmpi.b	#$7A,d1         ; LATIN SMALL LETTER Z
		bls.b	.toup
		cmpi.b	#$E0,d1         ; LATIN SMALL LETTER A WITH GRAVE
		blo.b	.done
		cmpi.b	#$FE,d1         ; LATIN SMALL LETTER THORN
		bhi.b	.done
		cmpi.b	#$F7,d1         ; DIVISION SIGN
		beq.b	.done
.toup:
		subi.b	#$20,d1
.done:
		rts

;
; REG(D0) LONG   len1,
; REG(A1) STRPTR str1End
; IStrMatchN(
; 	REG(A1) STRPTR str1,
; 	REG(D0) LONG   len2),
; REG(A2) STRPTR str2,
; REG(A3) APTR   upper)
;
; NOTES
; 	preserves all registers (except D0.L/A1.L)
; 	str1 is advanced by match len1, up to len2
; 	upper prototype: D1.B(D1.B), preserve D0.L
;
IStrMatchN:
		movem.l	d0-d2/a0/a2,-(sp)
.loop:
		subq.l	#1,d0
		bmi.b	.done
		move.b	(a2)+,d1
		jsr	(a3)
		move.b	d1,d2
		move.b	(a1)+,d1
		jsr	(a3)
		cmp.b	d1,d2
		beq.b	.loop
		subq.l	#1,a1
.done:
		addq.l	#1,d0
		sub.l	d0,(sp)
		movem.l	(sp)+,d0-d2/a0/a2
		rts

;
; REG(A0) STRPTR dstEnd
; IStrCopyN(
; 	REG(A0) STRPTR dst),
; REG(D0) LONG   max,
; REG(A2) STRPTR src
;
; NOTES
; 	preserves all registers (except A0.L/CCR)
; 	src must be a valid pointer (if max >= 1)
; 	copy stops on \0 character or max reached
; 	the result is always terminated with a \0
;
IStrCopyN:
		movem.l	d0/a2,-(sp)
.loop:
		subq.l	#1,d0
		bmi.b	.done
		move.b	(a2)+,(a0)+
		bne.b	.loop
		subq.l	#1,a0
.done:
		clr.b	(a0)
		movem.l	(sp)+,d0/a2
		rts

******* icon.library/BumpRevision ********************************************
*
*   NAME
*	BumpRevision -- reformat a name for a second copy.
*
*   SYNOPSIS
*	result = BumpRevision(newbuf, oldname)
*	D0                    A0      A1
*	STRPTR BumpRevision(STRPTR, STRPTR);
*
*   FUNCTION
*	BumpRevision takes a name and turns it into a "copy of name".
*	It knows how to deal with copies of copies. The routine will
*	truncate the new name to the maximum DOS name length (30).
*
*   INPUTS
*	newbuf -- the new buffer that will receive the name
*	          (it has to be at least 31 characters long)
*	oldname -- the original name
*
*   RESULTS
*	result -- a pointer to newbuf
*
*   NOTES
*	Extensions to the original behaviour:
*	- case-insensitive/'_' pattern support (WB2/WB3)
*	- leading '0's in revision numbers are preserved
*	- revision numbers aren't limited to signed long
*
******************************************************************************
IBumpRevision:
		movem.l	d0-d4/a0-a4,-(sp)
		move.l	a0,(sp)         ; (sp),result/*
		move.l	a1,-(sp)        ; (sp),oldname/result/*
		lea	.str2(pc),a2
		lea	IUpperBump(pc),a3
		moveq	#$30,d2         ; '0'
		moveq	#$39,d3         ; '9'
		moveq	#30-8,d4        ; max-"copy of "
		; new starts with "copy"
		bsr.b	.cpy4
		movea.l	a0,a4
		; match old with "copy of "
		moveq	#8,d0
		bsr.b	IStrMatchN
		addq.l	#4,a2           ; " of "
		; tmp append " 2"
		move.b	(a2),(a4)+
		move.b	#$32,(a4)+
		; old starts with "copy of "?
		subq.l	#8,d0
		beq.b	.nrev
		; old starts with "copy "?
		addq.l	#8-5,d0
		bne.b	.cpof
		; tmp change "0<oldrev>"
		subq.l	#2,a4
		move.b	d2,(a4)+
.orev:
		addq.l	#1,d0
		cmp.b	(a1),d2
		bhi.b	.isof
		cmp.b	(a1),d3
		blo.b	.isof
		move.b	(a1)+,(a4)+
		bra.b	.orev
;---------------------------------------
.isof:
		; save tmp length
		move.l	d0,d1
		; old continues with " of "?
		moveq	#4,d0
		bsr.b	IStrMatchN
		subq.l	#4,d0
		bne.b	.cpof
		; tmp change "0<newrev>"
.irev:
		addq.l	#1,d0
		addq.b	#1,-(a4)
		cmp.b	(a4),d3
		bhs.b	.frev
		move.b	d2,(a4)
		bra.b	.irev
;---------------------------------------
.cpy4:
		moveq	#4,d0
.cpyn:
		bra.b	IStrCopyN
	;	rts
;---------------------------------------
.nrev:
		; tmp change " "...
		move.b	(a2),(a0)
		; accept pos
		move.l	a1,(sp)         ; (sp),oldname/*
		; accept tmp
		suba.l	a0,a4
		adda.l	a4,a0
		; reduce max
		sub.l	a4,d4
.cpof:
		movea.l	(sp)+,a1        ; (sp),oldname/result/*
		; new append " of "
		bsr.b	.cpy4
		; new append max name
		bsr.w	IStrLen
		cmp.l	d4,d0
		bls.b	.name
		move.l	d4,d0
.name:
		movea.l	a1,a2
		bsr.b	.cpyn
		movem.l	(sp)+,d0-d4/a0-a4
		rts
;---------------------------------------
.frev:
		adda.l	d0,a4
		; tmp starts with '1'?
		cmp.l	d1,d0
		bne.b	.nrev
		; tmp length overflow?
		cmp.l	d4,d0
		bhs.b	.cpof
		; tmp move 1 to right
		movea.l	a4,a0
		addq.l	#1,a4
.mrev:
		move.b	-(a0),-(a4)
		subq.l	#1,d1
		bne.b	.mrev
		bra.b	.frev
;---------------------------------------
.str2:
		; "Copy_of_" in WB2/WB3
		dc.b	"copy of "

	align	2
iconEnd:
