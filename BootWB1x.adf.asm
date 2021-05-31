; vasmm68k_mot[_<HOST>] -Fbin -pic -o BootWB1x.adf BootWB1x.adf.asm
sector0_1:
BBLOCK0X_DOSVER EQU 0
BBLOCK0X_NOINFO EQU 1
	include	BBlock0x.bb.asm

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
		dc.l	$0B659CA8               ; rb_Checksum (BootWB1x.adf.py)
		dcb.l	72,0                    ; rb_HashTable
		dc.l	-1                      ; TD_SECTOR+vrb_BitmapFlag
		dc.l	881                     ; TD_SECTOR+vrb_Bitmap
		dcb.l	25-1,0                  ;
		dc.l	0                       ; TD_SECTOR+vrb_BitExtend
		; 9B 3F 7E is the raw input sequence for the Help key :-]
		dc.l	('9'<<8)!'B'            ; TD_SECTOR+vrb_Days = 2018-02-18
		dc.l	'?'                     ; TD_SECTOR+vrb_Mins = 01:03
		dc.l	'~'                     ; TD_SECTOR+vrb_Ticks = 02.52
		dc.b	8,"BootWB1x"            ; TD_SECTOR+vrb_Name
		dcb.b	36-1-8,0                ;
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
		dc.l	$C000C037               ; checksum (BootWB1x.adf.py)
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
