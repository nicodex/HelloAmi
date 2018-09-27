; vasmm68k_mot -Fbin -DHELLOICO_TYPE=1 -o Disk.info HelloIco.asm
; vasmm68k_mot -Fbin -DHELLOICO_TYPE=3 -o HelloAmi.info HelloIco.asm

		dc.w	$E310           ; do_Magic = WB_DISKMAGIC
		dc.w	1               ; do_Version = WB_DISKVERSION
		dc.l	0               ; do_Gadget+gg_NextGadget
		dc.w	0,0             ; do_Gadget+gg_LeftEdge/gg_TopEdge
		dc.w	48,18+1         ; do_Gadget+gg_Width/gg_Height
		dc.w	$0004!$0001     ; do_Gadget+gg_Flags =
		    	                ; 	GFLG_GADGIMAGE!
		    	                ; 	GFLG_GADGBACKFILL
		dc.w	$0001!$0002     ; do_Gadget+gg_Activation =
		    	                ; 	GACT_RELVERIFY!
		    	                ; 	GACT_IMMEDIATE
		dc.w	$0001           ; do_Gadget+gg_GadgetType =
		    	                ; 	GTYP_BOOLGADGET
		dc.l	-1              ; do_Gadget+gg_GadgetRender = DOSTRUE
		dc.l	0               ; do_Gadget+gg_SelectRender = DOSFALSE
		dc.l	0               ; do_Gadget+gg_GadgetText
		dc.l	0               ; do_Gadget+gg_MutualExclude
		dc.l	0               ; do_Gadget+gg_SpecialInfo
		dc.w	0               ; do_Gadget+gg_GadgetID
		dc.l	0               ; do_Gadget+gg_UserData = OS 1.x icon
		dc.b	HELLOICO_TYPE   ; do_Type
		dc.b	0               ; do_pad
	ifeq HELLOICO_TYPE-1
		dc.l	-1              ; do_DefaultTool
	else
		dc.l	0               ; do_DefaultTool
	endif
		dc.l	0               ; do_ToolTypes
		dc.l	$80000000       ; do_CurrentX = NO_ICON_POSITION
		dc.l	$80000000       ; do_CurrentY = NO_ICON_POSITION
	ifle HELLOICO_TYPE-2
		dc.l	-1              ; do_DrawerData
	else
		dc.l	0               ; do_DrawerData
	endif
		dc.l	0               ; do_ToolWindow
		dc.l	0               ; do_StackSize

	ifle HELLOICO_TYPE-2
		dc.w	50,50           ; dd_NewWindow.nw_LeftEdge/nw_TopEdge
		dc.w	400,100         ; dd_NewWindow.nw_Width/nw_Height
		dc.b	-1,-1           ; dd_NewWindow.nw_DetailPen/nw_BlockPen
		dc.l	0               ; dd_NewWindow.nw_IDCMPFlags
		dc.l	$0000127F       ; dd_NewWindow.nw_Flags =
		    	                ; 	WFLG_SIZEGADGET!
		    	                ; 	WFLG_DRAGBAR!
		    	                ; 	WFLG_DEPTHGADGET!
		    	                ; 	WFLG_CLOSEGADGET!
		    	                ; 	WFLG_SIZEBRIGHT!
		    	                ; 	WFLG_SIZEBBOTTOM!
		    	                ; 	WFLG_SIMPLE_REFRESH!
		    	                ; 	WFLG_REPORTMOUSE!
		    	                ; 	WFLG_ACTIVATE
		dc.l	0               ; dd_NewWindow.nw_FirstGadget
		dc.l	0               ; dd_NewWindow.nw_CheckMark
		dc.l	0               ; dd_NewWindow.nw_Title
		dc.l	0               ; dd_NewWindow.nw_Screen
		dc.l	0               ; dd_NewWindow.nw_BitMap
		dc.w	90,40           ; dd_NewWindow.nw_MinWidth/nw_MinHeight
		dc.w	-1,-1           ; dd_NewWindow.nw_MaxWidth/nw_MaxHeight
		dc.w	1               ; dd_NewWindow.nw_Type = WBENCHSCREEN
		dc.l	0,0             ; dd_CurrentX/dd_CurrentY
	endif

		dc.w	0,0             ; ig_LeftEdge/ig_TopEdge
		dc.w	48,18,2         ; ig_Width/ig_Height/ig_Depth
		dc.l	-1              ; ig_ImageData
		dc.b	$03,$00         ; ig_PlanePick/ig_PlaneOnOff
		dc.l	0               ; ig_NextImage

		dc.w	%0000000000000000,%0000000000000000,%0000000000000000
		dc.w	%0001111111111111,%1111111111111111,%1111111111111000
		dc.w	%0111100000000000,%0000000000000000,%0000000000011110
		dc.w	%0110000000000000,%0000000000000000,%0000000000000110
		dc.w	%0110000111000000,%0000000011100111,%0000000000000110
		dc.w	%0110000011000000,%0000000001100011,%0000000000000110
		dc.w	%0110000011011100,%0111110001100011,%0001111100000110
		dc.w	%0110000011100110,%1100011001100011,%0011000110000110
		dc.w	%0110000011000110,%1111111001100011,%0011000110000110
		dc.w	%0110000011000110,%1100000001100011,%0011000110000110
		dc.w	%0110000111000110,%0111110011110111,%1001111100000110
		dc.w	%0110000000000000,%0000000000000000,%0000000000000110
		dc.w	%0111100000000000,%0000000000000000,%0000000000011110
		dc.w	%0001111111111111,%1111000000111111,%1111111111111000
		dc.w	%0000000000000000,%0011000011100000,%0000000000000000
		dc.w	%0000000000000000,%1100011110000000,%0000000000000000
		dc.w	%0000000000000001,%1111110000000000,%0000000000000000
		dc.w	%0000000000000000,%0000000000000000,%0000000000000000

		dc.w	%0000000000000000,%0000000000000000,%0000000000000000
		dc.w	%0001111111111111,%1111111111111111,%1111111111111000
		dc.w	%0111111111111111,%1111111111111111,%1111111111111110
		dc.w	%0111111111111111,%1111111111111111,%1111111111111110
		dc.w	%0111111000111111,%1111111100011000,%1111111111111110
		dc.w	%0111111100111111,%1111111110011100,%1111111111111110
		dc.w	%0111111100100011,%1000001110011100,%1110000011111110
		dc.w	%0111111100011001,%0011100110011100,%1100111001111110
		dc.w	%0111111100111001,%0000000110011100,%1100111001111110
		dc.w	%0111111100111001,%0011111110011100,%1100111001111110
		dc.w	%0111111000111001,%1000001100001000,%0110000011111110
		dc.w	%0111111111111111,%1111111111111111,%1111111111111110
		dc.w	%0111111111111111,%1111111111111111,%1111111111111110
		dc.w	%0001111111111111,%1111111111111111,%1111111111111000
		dc.w	%0000000000000000,%0011111111100000,%0000000000000000
		dc.w	%0000000000000000,%1111111110000000,%0000000000000000
		dc.w	%0000000000000001,%1111110000000000,%0000000000000000
		dc.w	%0000000000000000,%0000000000000000,%0000000000000000

	ifeq HELLOICO_TYPE-1
		dc.l	$00000014
		dc.b	"SYS:System/DiskCopy",0
	endif
