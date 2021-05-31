; vasmm68k_mot[_<HOST>] -Fbin -o icon_36_336/def_project.info def_project-icon_36_336.asm
;
; Default "ENV:def_project.info" data included in "icon 36.336 (8.6.90)".
;
	include	deficon.inc

	ifne	DEFICON_MEM
		align	1
	endif
defIconProject:
		dc.w	$E310                   ; do_Magic = WB_DISKMAGIC
		dc.w	$0001                   ; do_Version = WB_DISKVERSION
		dc.l	0                       ; do_Gadget+gg_NextGadget
		dc.w	169,46                  ; do_Gadget+gg_LeftEdge/gg_TopEdge
		dc.w	54,22                   ; do_Gadget+gg_Width/gg_Height
		dc.w	$0005                   ; do_Gadget+gg_Flags =
		    	                        ;       GFLG_GADGBACKFILL
		    	                        ;       GFLG_GADGIMAGE
		dc.w	$0001                   ; do_Gadget+gg_Activation =
		    	                        ;       GACT_RELVERIFY
		dc.w	$0001                   ; do_Gadget+gg_GadgetType =
		    	                        ;       GTYP_BOOLGADGET
		DEFICON_PTR	.GadgetRender   ; do_Gadget+gg_GadgetRender
		dc.l	0                       ; do_Gadget+gg_SelectRender
		dc.l	0                       ; do_Gadget+gg_GadgetText
		dc.l	0                       ; do_Gadget+gg_MutualExclude
		dc.l	0                       ; do_Gadget+gg_SpecialInfo
		dc.w	0                       ; do_Gadget+gg_GadgetID
		dc.l	0                       ; do_Gadget+gg_UserData
		dc.b	4                       ; do_Type = WBPROJECT
		dc.b	0                       ; do_PAD_BYTE
		DEFICON_PTR	.DefaultTool    ; do_DefaultTool
		dc.l	0                       ; do_ToolTypes
		dc.l	$80000000               ; do_CurrentX = NO_ICON_POSITION
		dc.l	$80000000               ; do_CurrentY = NO_ICON_POSITION
		dc.l	0                       ; do_DrawerData
		dc.l	0                       ; do_ToolWindow
		dc.l	0                       ; do_StackSize

.GadgetRender:
		dc.w	0,0                     ; ig_LeftEdge/ig_TopEdge
		dc.w	54,22                   ; ig_Width/ig_Height
		dc.w	2                       ; ig_Depth
		DEFICON_PTR	.GadgetImage    ; ig_ImageData
		dc.b	(1<<2)-1,0              ; ig_PlanePick/ig_PlaneOnOff
		dc.l	0                       ; ig_NextImage

.GadgetImage:
		dc.w	%0000000000000000,%0000000000000000,%0000000000000100,%0000000000000000
		dc.w	%0000000000000000,%0000000000000000,%0000000000000001,%0000000000000000
		dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0100000000000000
		dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0001000000000000
		dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000100000000000
		dc.w	%0000000000000000,%1110000000000000,%0000000000000000,%0000110000000000
		dc.w	%0000000000000001,%1111000000000000,%0000000000000000,%0000110000000000
		dc.w	%0000000000000011,%1011100000000000,%0000000000000000,%0000110000000000
		dc.w	%0000000000000111,%0001110000000000,%0000000000000000,%0000110000000000
		dc.w	%0000000000001110,%0000111000000000,%0000000000000000,%0000110000000000
		dc.w	%0000000000011100,%0000011100000000,%0000000000000000,%0000110000000000
		dc.w	%0000000000111111,%1111111110000000,%0111111111110000,%0000110000000000
		dc.w	%0000000000011111,%1111111110000000,%0000000000000000,%0000110000000000
		dc.w	%0000000000000000,%0000000000000000,%0111111000000000,%0000110000000000
		dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000110000000000
		dc.w	%0000000000000000,%0000000000011111,%1111111111111100,%0000110000000000
		dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000110000000000
		dc.w	%0000000000000000,%0000000000011111,%1111111111000000,%0000110000000000
		dc.w	%0100000000000000,%0000000000000000,%0000000000000000,%0000110000000000
		dc.w	%0001000000000000,%0000000000000000,%0000000000000000,%0000110000000000
		dc.w	%0000010000000000,%0000000000000000,%0000000000000000,%0000110000000000
		dc.w	%0000000111111111,%1111111111111111,%1111111111111111,%1111110000000000

		dc.w	%1111111111111111,%1111111111111111,%1111111111111000,%0000000000000000
		dc.w	%1101010101010101,%0101010101010101,%0101010101010110,%0000000000000000
		dc.w	%1101010101010101,%0101010101010101,%0101010101010101,%1000000000000000
		dc.w	%1101111111111111,%1111111111111111,%0101010101010101,%0110000000000000
		dc.w	%1101000000000000,%0000000000000001,%0101010101010101,%0101000000000000
		dc.w	%1101000000000000,%1100000000000001,%0101010101010101,%0101000000000000
		dc.w	%1101000000000001,%1110000000000001,%0101010101010101,%0101000000000000
		dc.w	%1101000000000011,%0011000000000001,%0101010101010101,%0101000000000000
		dc.w	%1101000000000110,%0001100000000001,%0111111111111111,%0101000000000000
		dc.w	%1101000000001100,%0000110000000001,%0111111111111111,%0101000000000000
		dc.w	%1101000000011000,%0000011000000001,%0111111111111111,%0101000000000000
		dc.w	%1101000000111111,%1111111100000001,%0000000000001111,%0101000000000000
		dc.w	%1101000000000000,%0000000000000001,%0111111111111111,%0101000000000000
		dc.w	%1101000000000000,%0000000000000001,%0000000111111111,%0101000000000000
		dc.w	%1101111111111111,%1111111111111111,%0111111111111111,%0101000000000000
		dc.w	%1101010101010101,%0101010111100000,%0000000000000011,%0101000000000000
		dc.w	%1101010101010101,%0101010111111111,%1111111111111111,%0101000000000000
		dc.w	%1101010101010101,%0101010111100000,%0000000000111111,%0101000000000000
		dc.w	%0011010101010101,%0101010111111111,%1111111111111111,%0101000000000000
		dc.w	%0000110101010101,%0101010111111111,%1111111111111111,%0101000000000000
		dc.w	%0000001101010101,%0101010101010101,%0101010101010101,%0101000000000000
		dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000

.DefaultTool:
		DEFICON_STR	"SYS:Utilities/More"

