; vasmm68k_mot[_<HOST>] -Fbin -o icon_36_336/def_disk.info def_disk-icon_36_336.asm
;
; Default "ENV:def_disk.info" data included in "icon 36.336 (8.6.90)".
;
	include	deficon.inc

	ifne	DEFICON_MEM
		align	1
	endif
defIconDisk:
		dc.w	$E310                   ; do_Magic = WB_DISKMAGIC
		dc.w	$0001                   ; do_Version = WB_DISKVERSION
		dc.l	0                       ; do_Gadget+gg_NextGadget
		dc.w	0,0                     ; do_Gadget+gg_LeftEdge/gg_TopEdge
		dc.w	36,17                   ; do_Gadget+gg_Width/gg_Height
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
		dc.w	36,17                   ; ig_Width/ig_Height
		dc.w	2                       ; ig_Depth
		DEFICON_PTR	.GadgetImage    ; ig_ImageData
		dc.b	(1<<2)-1,0              ; ig_PlanePick/ig_PlaneOnOff
		dc.l	0                       ; ig_NextImage

.GadgetImage:
		dc.w	%0111111111000000,%0000000000001111,%1100000000000000
		dc.w	%0111111111000000,%0000001110001111,%1111000000000000
		dc.w	%0111111111000000,%0000001110001111,%1111000000000000
		dc.w	%0111111111000000,%0000001110001111,%1111000000000000
		dc.w	%0111111111000000,%0000001110001111,%1111000000000000
		dc.w	%0111111111100000,%0000000000011111,%1111000000000000
		dc.w	%0111111111111111,%1111111111111111,%1111000000000000
		dc.w	%0111111111111111,%1111111111111111,%1111000000000000
		dc.w	%0111100000000000,%0000000000000000,%1111000000000000
		dc.w	%0111100000000000,%0000000000000000,%1111000000000000
		dc.w	%0111100000000000,%0000000110110000,%1111000000000000
		dc.w	%0111100000000000,%0000001101100000,%1111000000000000
		dc.w	%0111100000000000,%0000011011000000,%1111000000000000
		dc.w	%0111100000000110,%1100110110000000,%1111000000000000
		dc.w	%0111100000000011,%0111101100000000,%1111000000000000
		dc.w	%0100100000000001,%1011011000000000,%1111000000000000
		dc.w	%0111100000000000,%0000000000000000,%1111000000000000

		dc.w	%1000000000111111,%1111111111110000,%0000000000000000
		dc.w	%1000000000111111,%1111110001110000,%0000000000000000
		dc.w	%1000000000111111,%1111110001110000,%0000000000000000
		dc.w	%1000000000111111,%1111110001110000,%0000000000000000
		dc.w	%1000000000111111,%1111110001110000,%0000000000000000
		dc.w	%1000000000011111,%1111111111100000,%0000000000000000
		dc.w	%1000000000000000,%0000000000000000,%0000000000000000
		dc.w	%1000000000000000,%0000000000000000,%0000000000000000
		dc.w	%1000011111111111,%1111111111111111,%0000000000000000
		dc.w	%1000011111111111,%1111111111111111,%0000000000000000
		dc.w	%1000011111111111,%1111111001001111,%0000000000000000
		dc.w	%1000011111111111,%1111110010011111,%0000000000000000
		dc.w	%1000011111111111,%1111100100111111,%0000000000000000
		dc.w	%1000011111111001,%0011001001111111,%0000000000000000
		dc.w	%1000011111111100,%1000010011111111,%0000000000000000
		dc.w	%1001011111111110,%0100100111111111,%0000000000000000
		dc.w	%1000011111111111,%1111111111111111,%0000000000000000

.DefaultTool:
		DEFICON_STR	"SYS:System/DiskCopy"


