; vasmm68k_mot[_<HOST>] -Fbin -o icon_36_336/def_kick.info def_kick-icon_36_336.asm
;
; Default "ENV:def_kick.info" data included in "icon 36.336 (8.6.90)".
;
	include	deficon.inc

	ifne	DEFICON_MEM
		align	1
	endif
defIconKick:
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
		dc.b	7                       ; do_Type = WBKICK
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


