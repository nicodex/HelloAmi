; vasmm68k_mot[_<HOST>] -Fbin -o icon_36_214/def_disk.info def_disk-icon_36_214.asm
;
; Default "ENV:def_disk.info" data included in "icon 36.214 (11 Dec 1989)".
; Note that this icon data is never used (GetDefDiskObject returns NULL).
;
	include	deficon.inc

	ifne	DEFICON_MEM
		align	1
	endif
defIconDisk:
		dc.w	$E310                   ; do_Magic = WB_DISKMAGIC
		dc.w	$0001                   ; do_Version = WB_DISKVERSION
		dc.l	0                       ; do_Gadget+gg_NextGadget
		dc.w	559,35                  ; do_Gadget+gg_LeftEdge/gg_TopEdge
		dc.w	80,16                   ; do_Gadget+gg_Width/gg_Height
		dc.w	$0004                   ; do_Gadget+gg_Flags =
		    	                        ;       GFLG_GADGIMAGE
		dc.w	$0003                   ; do_Gadget+gg_Activation =
		    	                        ;       GACT_RELVERIFY
		    	                        ;       GACT_IMMEDIATE
		dc.w	$0001                   ; do_Gadget+gg_GadgetType =
		    	                        ;       GTYP_BOOLGADGET
		DEFICON_PTR	.GadgetRender   ; do_Gadget+gg_GadgetRender
		dc.l	0                       ; do_Gadget+gg_SelectRender
		dc.l	0                       ; do_Gadget+gg_GadgetText
		dc.l	0                       ; do_Gadget+gg_MutualExclude
		dc.l	0                       ; do_Gadget+gg_SpecialInfo
		dc.w	0                       ; do_Gadget+gg_GadgetID
		dc.l	0                       ; do_Gadget+gg_UserData
		dc.b	1                       ; do_Type = WBDISK
		dc.b	0                       ; do_PAD_BYTE
		DEFICON_PTR	.DefaultTool    ; do_DefaultTool
		dc.l	0                       ; do_ToolTypes
		dc.l	$80000000               ; do_CurrentX = NO_ICON_POSITION
		dc.l	$80000000               ; do_CurrentY = NO_ICON_POSITION
		DEFICON_PTR	.DrawerData     ; do_DrawerData
		dc.l	0                       ; do_ToolWindow
		dc.l	0                       ; do_StackSize

.DrawerData:
		dc.w	0,11                    ; dd_NewWindow+nw_LeftEdge/nw_TopEdge
		dc.w	320,100                 ; dd_NewWindow+nw_Width/nw_Height
		dc.b	-1,-1                   ; dd_NewWindow+nw_DetailPen/nw_BlockPen
		dc.l	0                       ; dd_NewWindow+nw_IDCMPFlags
		dc.l	$0240027F               ; dd_NewWindow+nw_Flags =
		    	                        ;       WFLG_SIZEGADGET
		    	                        ;       WFLG_DRAGBAR
		    	                        ;       WFLG_DEPTHGADGET
		    	                        ;       WFLG_CLOSEGADGET
		    	                        ;       WFLG_SIZEBRIGHT
		    	                        ;       WFLG_SIZEBBOTTOM
		    	                        ;       WFLG_SIMPLE_REFRESH
		    	                        ;       WFLG_REPORTMOUSE
		    	                        ;       $00400000
		    	                        ;       WFLG_WBENCHWINDOW
		dc.l	0                       ; dd_NewWindow+nw_FirstGadget
		dc.l	0                       ; dd_NewWindow+nw_CheckMark
		dc.l	0                       ; dd_NewWindow+nw_Title
		dc.l	0                       ; dd_NewWindow+nw_Screen
		dc.l	0                       ; dd_NewWindow+nw_BitMap
		dc.w	90,40                   ; dd_NewWindow+nw_MinWidth/nw_MinHeight
		dc.w	65535,65535             ; dd_NewWindow+nw_MaxWidth/nw_MaxHeight
		dc.w	$0001                   ; dd_NewWindow+nw_Type = WBENCHSCREEN
		dc.l	18,0                    ; dd_CurrentX/CurrentY
	ifne	DEFICON_MEM
		dc.l	0                       ; dd_Flags
		dc.w	0                       ; dd_ViewModes
	endif

.GadgetRender:
		dc.w	0,0                     ; ig_LeftEdge/ig_TopEdge
		dc.w	35,16                   ; ig_Width/ig_Height
		dc.w	2                       ; ig_Depth
		DEFICON_PTR	.GadgetImage    ; ig_ImageData
		dc.b	(1<<2)-1,0              ; ig_PlanePick/ig_PlaneOnOff
		dc.l	0                       ; ig_NextImage

.GadgetImage:
		dc.w	%0000001111111111,%1111111111111000,%0000000000000000
		dc.w	%0000001111111111,%1111101010101000,%0000000000000000
		dc.w	%0000001111111111,%1111010101011000,%0000000000000000
		dc.w	%0000001111111111,%1110101010111000,%0000000000000000
		dc.w	%0000001100010001,%1101010101111000,%0000000000000000
		dc.w	%0000001110001000,%1010101011111000,%0000000000000000
		dc.w	%0000001111000100,%0101010111111000,%0000000000000000
		dc.w	%0000000111100010,%1010101111111000,%0000000000000000
		dc.w	%0000000000000000,%0000000000000000,%0000000000000000
		dc.w	%0000000000000000,%0000000000000000,%0000000000000000
		dc.w	%0000000001111111,%1111111111000000,%0000000000000000
		dc.w	%0000000001110000,%1111111111000000,%0000000000000000
		dc.w	%0000000001110000,%1111111111000000,%0000000000000000
		dc.w	%0000000001110000,%1111111111000000,%0000000000000000
		dc.w	%0000000001111111,%1111111111000000,%0000000000000000
		dc.w	%0000000000000000,%0000000000000000,%0000000000000000

		dc.w	%1111110000000000,%0000000000000111,%1110000000000000
		dc.w	%1111110000000000,%0000011101110110,%0110000000000000
		dc.w	%1111110000000000,%0000111011100111,%1110000000000000
		dc.w	%1111110000000000,%0001110111000111,%1110000000000000
		dc.w	%1111110010101010,%0011101110000111,%1110000000000000
		dc.w	%1111110001010101,%0111011100000111,%1110000000000000
		dc.w	%1111110000101010,%1110111000000111,%1110000000000000
		dc.w	%1111111000010101,%1111110000000111,%1110000000000000
		dc.w	%1111111111111111,%1111111111111111,%1110000000000000
		dc.w	%1111111111111111,%1111111111111111,%1110000000000000
		dc.w	%1111111111111111,%1111111111111111,%1110000000000000
		dc.w	%1111111111111111,%1111111111111111,%1110000000000000
		dc.w	%1111111111111111,%1111111111111111,%1110000000000000
		dc.w	%0111111111111111,%1111111111111111,%1110000000000000
		dc.w	%0011111111111111,%1111111111111111,%1110000000000000
		dc.w	%0000000000000000,%0000000000000000,%0000000000000000

.DefaultTool:
		DEFICON_STR	"SYS:System/DiskCopy"


