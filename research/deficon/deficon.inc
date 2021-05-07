
	ifnd	DEFICON_MEM
DEFICON_MEM	equ	0
	endif

	ifmacrond	DEFICON_PTR
	macro	DEFICON_PTR
	ifeq	DEFICON_MEM
		dc.l	-1      ; DOSTRUE
	else
		dc.l	\1
	endif
	endm
	endif

	ifmacrond	DEFICON_STR
	macro	DEFICON_STR
	ifeq	DEFICON_MEM
		dc.l	.end\@-.str\@
	endif
.str\@:
		dc.b	\1,0
.end\@:
	endm
	endif


