; vasmm68k_mot[_<HOST>] -Fbin -pic -o HelloAmi.adf HelloAmi.adf.asm
sector0_1:
		dc.b	'DOS',0                 ; BB_ID = BBID_DOS
		dc.l	$2ACF8EAD               ; BB_CHKSUM (HelloAmi.adf.py)
		dc.l	880                     ; BB_DOSBLOCK = ST_ROOT sector
;
; BootBlock entry point
;
; 	Called by strap with SysBase in A6 and the I/O request in A1.
; 	Expects result in D0 (non-zero = AN_BootError) and boot code
; 	entry point address in A0. The boot code is called after the
; 	strap module freed all resources (includes this two sectors)!
;
		; MOVEM- order: A7/A6/A5/A4/A3/A2/A1/A0/D7/D6/D5/D4/D3/D2/D1/D0
		movem.l	a3/a2/a0,-(sp)          ; thereafter: (SP) = A0
		;
		; this is part of the standard OS 2.x/3.x BootBlock
		; (SILENTSTART is disabled by default for floppies)
		;
		lea	.expName,a1
		moveq	#37,d0
		jsr	-$0228(a6)              ; _LVOOpenLibrary
		tst.l	d0
		beq.b	.findDos
		movea.l	d0,a1
		bset	#6,$0022(a1)            ; eb_Flags |= 1<<EBB_SILENTSTART
		jsr	-$019E(a6)              ; _LVOCloseLibrary
.findDos:
		;
		; this is part of any standard BootBlock
		; (return the dos.library init function)
		;
		lea	.dosName(pc),a1
		jsr	-$0060(a6)              ; _LVOFindResident
		tst.l	d0
		beq.b	.bootErr
		movea.l	d0,a0
		move.l	$0016(a0),(sp)          ; RT_INIT
		bne.b	.findInt
.bootErr:
		;
		; something went wrong (strap alerts an AN_BootError)
		;
		moveq	#-1,d0
.bootRet:
		; MOVEM+ order: D0/D1/D2/D3/D4/D5/D6/D7/A0/A1/A2/A3/A4/A5/A6/A7
		movem.l	(sp)+,a0/a2/a3
		rts
.findInt:
		;
		; the "Hello, World!" task needs the intuition.library
		; (expected to be added during system and/or dos init)
		; 
		lea	intName(pc),a1
		jsr	-$0060(a6)              ; _LVOFindResident
		tst.l	d0
		beq.b	.bootRet
		;
		; allocate a MemList with one big entry for all the
		; CODE/DATA/BBS, and add it to the task memory list
		; (will be freed when the task is removed or ends).
		;
		lea	.memList(pc),a0
		jsr	-$00DE(a6)              ; _LVOAllocEntry
		tst.l	d0
		bmi.b	.bootErr
		movea.l	d0,a1
		movea.l	$0010(a1),a0            ; ML_ME+0*ME_SIZE+ME_ADDR
		; skip STACK
		lea	$1000(a0),a2            ; USRSTK_SIZE
		; copy task CODE (has to be longword-aligned)
		lea	TaskCode(pc),a3
		moveq	#(TaskData-TaskCode)/4-1,d0
.memCopy:
		move.l	(a3)+,(a2)+
		dbf	d0,.memCopy
		; now points to DATA/BBS (starts with the TCB)
		move.l	a0,$003A(a2)            ; TC_SPLOWER
		lea.l	$1000(a0),a0            ; USRSTK_SIZE
		move.l	a0,$003E(a2)            ; TC_SPUPPER
		move.l	a0,$0036(a2)            ; TC_SPREG
		move.w	#$0188,$0008(a2)        ; LN_TYPE/LN_PRI = NT_TASK/-120
		lea	taskName-TaskData(a2),a0
		move.l	a0,$000A(a2)            ; LN_NAME
		; NewList/AddHead
		lea	$004A(a2),a0            ; TC_MEMENTRY
		move.l	a1,(a0)                 ; LH_HEAD
		move.l	a1,$0008(a0)            ; LH_TAILPRED
		move.l	a0,$0004(a1)            ; LN_PRED
		addq.l	#4,a0                   ; LH_TAIL
		move.l	a0,(a1)                 ; LN_SUCC
		; clear caches (do not use a 68020+ with a 1.x ROM)
		cmpi.w	#37,$0014(a6)           ; LIB_VERSION
		blt.b	.addTask
		jsr	-$027C(a6)              ; _LVOCacheClearU
.addTask:
		movea.l	a2,a1
		lea	TaskCode-TaskData(a2),a2
		suba.l	a3,a3
		jsr	-$011A(a6)              ; _LVOAddTask
		; return value cannot be verified for pre-V36
		moveq	#0,d0                   ; return OK
		bra.b	.bootRet
		;
		; the MemList.ml_Node is not used by AllocEntry(),
		; so we can overlap it with the name to save bytes
		;
.dosName:
		dc.b	"dos.library",0
	align	2
.expName:
		dc.b	"expa"
.memList:
		dc.b	"nsion.library",0       ; LN_SIZE
		dc.w	1                       ; ML_NUMENTRIES
		; ML_ME+0*ME_SIZE+ME_REQS = MEMF_CLEAR!MEMF_PUBLIC
		dc.l	$00010001
		; ML_ME+0*ME_SIZE+ME_LENGTH =
		; 	USRSTK_SIZE+            ; task stack
		; 	(TaskData-TaskCode)+    ; task code
		; 	TC_SIZE+                ; task TCB
		; 	it_SIZEOF+              ; UI string
		; 	gg_SIZEOF+              ; UI gadget
		; 	nw_SIZEOF               ; UI window
		dc.l	$1000+(TaskData-TaskCode)+$005C+$0014+$002C+$0030;
;
; "Hello, World!" task
;
	align	2
TaskCode:
		; MOVEM- order: A7/A6/A5/A4/A3/A2/A1/A0/D7/D6/D5/D4/D3/D2/D1/D0
		movem.l	a6/a5/a2/d4/d3/d2/d0,-(sp) ; D0 for stack space (lib)
		movea.l	(4).w,a5                ; AbsExecBase
		movea.l	a5,a6
		;
		; try (forever) to open the intuition.library
		;
		lea	intName(pc),a2
.openInt:
		; any version will do, no newer functions used
		movea.l	a2,a1
		jsr	-$0198(a6)              ; _LVOOldOpenLibrary
		move.l	d0,(sp)
		beq.b	.openInt
		movea.l	d0,a6
		;
		; now try (forever) to open the "Hello, World!" window
		; (also creates a default public screen if not opened)
		;
		subq.l	#4,sp
		moveq	#1,d2                   ; GACT_RELVERIFY,
		     	                        ; GTYP_BOOLGADGET,
		     	                        ; WBENCHSCREEN,
		     	                        ; signal bit
		move.l	#(58<<16)+29,d3         ; left/top window and text
		move.l	#$00000240,d4           ; IDCMP_GADGETUP!
		      	                        ; IDCMP_CLOSEWINDOW
.openWin:
		lea	taskName(pc),a1
		lea	TaskData+$005C(pc),a0   ; TC_SIZE
		move.w	#-1,(a0)                ; it_FrontPen/it_BackPen
		move.l	d3,$0004(a0)            ; it_LeftEdge/it_TopEdge
		move.l	a1,$000C(a0)            ; it_IText
		lea	$0014+$000C(a0),a1      ; it_SIZEOF+gg_Flags
		move.w	#$0060,(a1)+            ; gg_Flags =
		      	                        ; 	GFLG_RELWIDTH!
		      	                        ; 	GFLG_RELHEIGHT
		move.w	d2,(a1)+                ; gg_Activation
		move.w	d2,(a1)                 ; gg_GadgetType
		lea	-$0010(a1),a1           ; -gg_GadgetType
		move.l	a0,$001A(a1)            ; gg_GadgetText
		lea	$002C(a1),a0            ; gg_SIZEOF
		move.l	d3,(a0)+                ; nw_LeftEdge/nw_TopEdge
		move.l	#(253<<16)+79,(a0)+     ; nw_Width/nw_Height
		move.w	#-1,(a0)+               ; nw_DetailPen/nw_BlockPen
		move.l	d4,(a0)+                ; nw_IDCMPFlags
		move.l	#$0000140E,(a0)+        ; nw_Flags =
		      	                        ; 	WFLG_DRAGBAR!
		      	                        ; 	WFLG_DEPTHGADGET!
		      	                        ; 	WFLG_CLOSEGADGET!
		      	                        ; 	WFLG_GIMMEZEROZERO!
		      	                        ; 	WFLG_ACTIVATE
		move.l	a1,(a0)+                ; nw_FirstGadget
		addq.l	#4,a0                   ; nw_CheckMark
		move.l	a2,(a0)                 ; nw_Title
		lea	-$001A(a0),a0           ; -nw_Title
		move.w	d2,$002E(a0)            ; nw_Type = WBENCHSCREEN
		jsr	-$00CC(a6)              ; _LVOOpenWindow
		move.l	d0,(sp)
		beq.b	.openWin
		movea.l	d0,a0
		; get the IDCMP message port and signal mask
		movea.l	$0056(a0),a2            ; wd_UserPort
		move.b	$000F(a2),d0            ; mp_SigBit
		lsl.l	d0,d2
.waitWin:
		;
		; now wait, read, and reply all messages (forever)...
		;
		movea.l	a5,a6
		move.l	d2,d0
		jsr	-$013E(a6)              ; _LVOWait
		and.l	d2,d0
		beq.b	.waitWin
		movea.l	a2,a0
		jsr	-$0174(a6)              ; _LVOGetMsg
		tst.l	d0
		beq.b	.waitWin
		movea.l	d0,a1
		move.l	$0014(a1),d3            ; im_Class
		jsr	-$017A(a6)              ; _LVOReplyMsg
		;
		; ...until the user releases the mouse select button over
		; the window's close gadget or the "Hello, World!" gadget
		;
		and.l	d4,d3                   ; any of nw_IDCMPFlags
		beq.b	.waitWin
		; cleanup and return (task is removed and memory is freed)
		movea.l	(sp)+,a0
		movea.l	(sp)+,a6
		jsr	-$0048(a6)              ; _LVOCloseWindow
		movea.l	a6,a1
		movea.l	a5,a6
		jsr	-$019E(a6)              ; _LVOCloseLibrary
		; MOVEM+ order: D0/D1/D2/D3/D4/D5/D6/D7/A0/A1/A2/A3/A4/A5/A6/A7
		movem.l	(sp)+,d2/d3/d4/a2/a5/a6
		rts
intName:
		dc.b	"intuition.library",0
taskName:
		dc.b	"Hello, World!",0
	align	2
TaskData:
		dcb.b	2*512-(TaskData-sector0_1)-80,0
HELLOROM_INFTD EQU ((2*512-(TaskData-sector0_1))/1000)
HELLOROM_INFTM EQU ((2*512-(TaskData-sector0_1))-(1000*HELLOROM_INFTD))
HELLOROM_INFHD EQU (HELLOROM_INFTM/100)
HELLOROM_INFHM EQU (HELLOROM_INFTM-(100*HELLOROM_INFHD))
HELLOROM_INFDD EQU (HELLOROM_INFHM/10)
HELLOROM_INFDM EQU (HELLOROM_INFHM-(10*HELLOROM_INFDD))
	ifeq HELLOROM_INFTD
		dc.b	' '
	else
		dc.b	HELLOROM_INFTD+'0'
	endif
	ifeq HELLOROM_INFTD+HELLOROM_INFHD
		dc.b	' '
	else
		dc.b	HELLOROM_INFHD+'0'
	endif
	ifeq HELLOROM_INFTD+HELLOROM_INFHD+HELLOROM_INFDD
		dc.b	' '
	else
		dc.b	HELLOROM_INFDD+'0'
	endif
		dc.b	HELLOROM_INFDM+'0'
		dc.b	    " bytes left "
		dc.b	" for boot block,"
		dc.b	" project at: htt"
		dc.b	"ps://github.com/"
		dc.b	"nicodex/HelloAmi"

;
; unused sectors
;
sector2_879:
		dcb.b	(879-2+1)*512,0

;
; ST_ROOT sector
;
sector880:
		dc.l	2                       ; rb_Type = T_SHORT
		dc.l	0                       ; rb_OwnKey
		dc.l	0                       ; rb_SeqNum
		dc.l	72                      ; rb_HTSize
		dc.l	0                       ; rb_Nothing1
		dc.l	$2247A76F               ; rb_Checksum (HelloAmi.adf.py)
		dcb.l	72,0                    ; rb_HashTable
		dc.l	-1                      ; TD_SECTOR+vrb_BitmapFlag
		dc.l	881                     ; TD_SECTOR+vrb_Bitmap
		dcb.l	25-1,0                  
		dc.l	0                       ; TD_SECTOR+vrb_BitExtend
		; 9B 3F 7E is the raw input sequence for the Help key :-]
		dc.l	('9'<<8)!'B'            ; TD_SECTOR+vrb_Days = 2018-02-18
		dc.l	'?'                     ; TD_SECTOR+vrb_Mins = 01:03
		dc.l	'~'                     ; TD_SECTOR+vrb_Ticks = 02.52
		dc.b	8,"HelloAmi"            ; TD_SECTOR+vrb_Name
		dcb.b	36-1-8,0                
		dc.l	0                       ; TD_SECTOR+vrb_Nothing4
		dc.l	('9'<<8)!'B','?','~'    ; TD_SECTOR+vrb_DiskMod
		dc.l	('9'<<8)!'B'            ; TD_SECTOR+vrb_CreateDays
		dc.l	'?'                     ; TD_SECTOR+vrb_CreateMins
		dc.l	'~'                     ; TD_SECTOR+vrb_CreateTicks
		dc.l	0                       ; TD_SECTOR+vrb_Nothing2
		dc.l	0                       ; TD_SECTOR+vrb_Nothing3
		dc.l	0                       ; TD_SECTOR+vrb_DirList
		dc.l	1                       ; TD_SECTOR+vrb_SecType = ST_ROOT

;
; Bitmap for sectors 2-1759
;
sector881:
		dc.l	$C000C037               ; checksum (HelloAmi.adf.py)
		dcb.l	27,$FFFFFFFF            ; 2-865 unused
		dc.l	$FFFF3FFF               ; 880/881 used
		dcb.l	26,$FFFFFFFF            ; 898-1729 unused
		dc.l	$3FFFFFFF               ; 1730-1759 unused
		dcb.l	72,0

;
; unused sectors
;
sector882_1759:
		dcb.b	(1759-882+1)*512,0

	if *-sector0_1-901120
		fail "Unexpected disk size, check sector size and count."
	endif
