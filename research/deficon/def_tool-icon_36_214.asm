; vasmm68k_mot[_<HOST>] -Fbin -o icon_36_214/def_tool.info def_tool-icon_36_214.asm
;
; Default "ENV:def_tool.info" data included in "icon 36.214 (11 Dec 1989)".
; Note that this icon data is never used (GetDefDiskObject returns NULL).
;
	include	deficon.inc

	ifne	DEFICON_MEM
		align	1
	endif
defIconTool:
		dc.w	$E310                   ; do_Magic = WB_DISKMAGIC
		dc.w	$0001                   ; do_Version = WB_DISKVERSION
		dc.l	0                       ; do_Gadget+gg_NextGadget
		dc.w	36,53                   ; do_Gadget+gg_LeftEdge/gg_TopEdge
		dc.w	31,18                   ; do_Gadget+gg_Width/gg_Height
		dc.w	$0005                   ; do_Gadget+gg_Flags =
		    	                        ;       GFLG_GADGBACKFILL
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
		dc.b	3                       ; do_Type = WBTOOL
		dc.b	0                       ; do_PAD_BYTE
		dc.l	0                       ; do_DefaultTool
		dc.l	0                       ; do_ToolTypes
		dc.l	$80000000               ; do_CurrentX = NO_ICON_POSITION
		dc.l	$80000000               ; do_CurrentY = NO_ICON_POSITION
		dc.l	0                       ; do_DrawerData
		dc.l	0                       ; do_ToolWindow
		dc.l	0                       ; do_StackSize

.GadgetRender:
		dc.w	0,0                     ; ig_LeftEdge/ig_TopEdge
		dc.w	31,17                   ; ig_Width/ig_Height
		dc.w	2                       ; ig_Depth
		DEFICON_PTR	.GadgetImage    ; ig_ImageData
		dc.b	(1<<2)-1,0              ; ig_PlanePick/ig_PlaneOnOff
		dc.l	0                       ; ig_NextImage

.GadgetImage:
		dc.w	%0000000000000000,%0000000000000000
		dc.w	%0000000000000000,%0000000000000000
		dc.w	%0000000000000110,%0000011000000000
		dc.w	%0000000000000110,%0000011000000000
		dc.w	%0000000000000110,%0000011000000000
		dc.w	%0000000000000000,%0000000000000000
		dc.w	%0011111111111111,%1111111111001000
		dc.w	%0011111111111111,%1111111111001000
		dc.w	%0011111111111111,%1111111111001000
		dc.w	%0011111111111111,%1111111111001000
		dc.w	%0011111111111111,%1111111111001000
		dc.w	%0011111111111111,%1111111111001000
		dc.w	%0011111111111111,%1111111111001000
		dc.w	%0011111111111111,%1111111111001000
		dc.w	%0011111111111111,%1111111111001000
		dc.w	%0011111111111111,%1111111111000000
		dc.w	%0000000000000000,%0000000000000000

		dc.w	%0000011000000110,%0000011000000000
		dc.w	%0000111100001111,%0000111100000000
		dc.w	%0001100110011001,%1001111110000000
		dc.w	%0001100110011001,%1001111110000000
		dc.w	%0001100110011001,%1001111110000000
		dc.w	%1111111111111111,%1111111111111110
		dc.w	%1100000000000000,%0000000000110110
		dc.w	%1100000000000000,%0000000000110110
		dc.w	%1100000000000000,%0000000000110110
		dc.w	%1100000000000000,%0000000000110110
		dc.w	%1100000000000000,%0000000000110110
		dc.w	%1100000000000000,%0000000000110110
		dc.w	%1100000000000000,%0000000000110110
		dc.w	%1100000000000000,%0000000000110110
		dc.w	%1100000000000000,%0000000000110110
		dc.w	%1100000000000000,%0000000000111100
		dc.w	%1111111111111111,%1111111111110000


