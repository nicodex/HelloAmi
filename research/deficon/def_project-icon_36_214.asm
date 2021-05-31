; vasmm68k_mot[_<HOST>] -Fbin -o icon_36_214/def_project.info def_project-icon_36_214.asm
;
; Default "ENV:def_project.info" data included in "icon 36.214 (11 Dec 1989)".
; Note that this icon data is never used (GetDefDiskObject returns NULL).
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
		dc.w	40,21                   ; do_Gadget+gg_Width/gg_Height
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
		dc.w	40,21                   ; ig_Width/ig_Height
		dc.w	2                       ; ig_Depth
		DEFICON_PTR	.GadgetImage    ; ig_ImageData
		dc.b	(1<<2)-1,0              ; ig_PlanePick/ig_PlaneOnOff
		dc.l	0                       ; ig_NextImage

.GadgetImage:
		dc.w	%0000000000000000,%0000000000000000,%0000000000000000
		dc.w	%0011111111111111,%1111111111001100,%0000000000000000
		dc.w	%0011111111111111,%1111111111001111,%0000000000000000
		dc.w	%0011111111111111,%1111111111001111,%1100000000000000
		dc.w	%0011100000000011,%1111111111001111,%1111000000000000
		dc.w	%0011111111111111,%1111111111000000,%0000000000000000
		dc.w	%0011100000000011,%1111111111111111,%1111110000000000
		dc.w	%0011111111111111,%1111111111111111,%1111110000000000
		dc.w	%0011111111111111,%1111111111111111,%1111110000000000
		dc.w	%0011111110000100,%0000000011000000,%0111110000000000
		dc.w	%0011111111111111,%1111111111111111,%1111110000000000
		dc.w	%0011100100000000,%1000000000000000,%0111110000000000
		dc.w	%0011111111111111,%1111111111111111,%1111110000000000
		dc.w	%0011100000000000,%0000000001000000,%0111110000000000
		dc.w	%0011111111111111,%1111111111111111,%1111110000000000
		dc.w	%0011111111111111,%1111111111111111,%1111110000000000
		dc.w	%0011111111111111,%1111111000000000,%0111110000000000
		dc.w	%0011111111111111,%1111111111111111,%1111110000000000
		dc.w	%0011111111111111,%1111111111111111,%1111110000000000
		dc.w	%0000000000000000,%0000000000000000,%0000000000000000
		dc.w	%0000000000000000,%0000000000000000,%0000000000000000

		dc.w	%1111111111111111,%1111111111111100,%0000000000000000
		dc.w	%1100000000000000,%0000000000110011,%0000000000000000
		dc.w	%1100000000000000,%0000000000110000,%1100000000000000
		dc.w	%1100000000000000,%0000000000110000,%0011000000000000
		dc.w	%1100011111111100,%0000000000110000,%0000110000000000
		dc.w	%1100000000000000,%0000000000111111,%1111111100000000
		dc.w	%1100011111111100,%0000000000000000,%0000001100000000
		dc.w	%1100000000000000,%0000000000000000,%0000001100000000
		dc.w	%1100000000000000,%0000000000000000,%0000001100000000
		dc.w	%1100000001111011,%1111111100111111,%1000001100000000
		dc.w	%1100000000000000,%0000000000000000,%0000001100000000
		dc.w	%1100011011111111,%0111111111111111,%1000001100000000
		dc.w	%1100000000000000,%0000000000000000,%0000001100000000
		dc.w	%1100011111111111,%1111111110111111,%1000001100000000
		dc.w	%1100000000000000,%0000000000000000,%0000001100000000
		dc.w	%1100000000000000,%0000000000000000,%0000001100000000
		dc.w	%1100000000000000,%0000000111111111,%1000001100000000
		dc.w	%1100000000000000,%0000000000000000,%0000001100000000
		dc.w	%1100000000000000,%0000000000000000,%0000001100000000
		dc.w	%1111111111111111,%1111111111111111,%1111111100000000
		dc.w	%0000000000000000,%0000000000000000,%0000000000000000

.DefaultTool:
		DEFICON_STR	"SYS:Utilities/More"


