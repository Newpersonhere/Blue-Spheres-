Test_LockOn:
		tst.w	(VDP_control_port).l
		move.w	#$4EF9,(V_int_jump).w	; machine code for jmp
		move.l	#VInt,(V_int_addr).w
		move.w	#$4EF9,(H_int_jump).w
		move.l	#HInt,(H_int_addr).w
-
		move.w	(VDP_control_port).l,d1
		btst	#1,d1
		bne.s	-	; wait till a DMA is completed
		lea	((RAM_start&$FFFFFF)).l,a6
		moveq	#0,d7
		move.w	#bytesToLcnt($FE00),d6
-
		move.l	d7,(a6)+
		dbf	d6,-

	if Sonic3_Complete
		moveq	#0,d1
		bra.s	SonicAndKnucklesStartup
	else
		move.b	#0,(SRAM_access_flag).l		; disable SRAM access
		lea	(SegaHeadersText).l,a1
		moveq	#1,d4	; test for both MEGA DRIVE and GENESIS

Test_SystemString:
		lea	(LockonHeader).l,a0
		moveq	#0,d3
		moveq	#$F,d2

$$compareChars:
		move.b	(a1)+,d0
		cmp.b	(a0)+,d0
		beq.s	$$matchingChar
		moveq	#1,d3

$$matchingChar:
		dbf	d2,$$compareChars
		tst.b	d3
		beq.s	DetermineWhichGame
		dbf	d4,Test_SystemString
		moveq	#-1,d1
		move.l	(SegaHeadersText).l,d0		; test to see if SEGA is at the locked on ROM's $100
		cmp.l	(LockonHeader).l,d0
		bne.w	SonicAndKnucklesStartup

DetermineWhichGame:
		lea	(LockonSerialsText).l,a1
		moveq	#3,d1	; 3 Sonic 2 headers, 1 Sonic 3 header

$$compareSerials:
		lea	(LockonSerialNumber).l,a0
		moveq	#0,d3
		moveq	#$D,d2

$$compareChars:
		move.b	(a1)+,d0
		cmp.b	(a0)+,d0
		beq.s	$$matchingChar
		moveq	#1,d3

$$matchingChar:
		dbf	d2,$$compareChars
		tst.b	d3
		beq.s	S2orS3LockedOn
		dbf	d1,$$compareSerials
		bra.s	BlueSpheresStartup
; ---------------------------------------------------------------------------

S2orS3LockedOn:
		tst.w	d1
		beq.w	SonicAndKnucklesStartup
		move.b	#1,(SRAM_access_flag).l
		jmp	($300000).l				; May be changed at a later date to become compatible with S2K disassembly
; ---------------------------------------------------------------------------
LockonSerialsText:
		dc.b "GM 00001051-00"	; Sonic 2 REV00/1/2
		dc.b "GM 00001051-01"
		dc.b "GM 00001051-02"
		dc.b "GM MK-1079 -00"	; Sonic 3
SegaHeadersText:dc.b "SEGA MEGA DRIVE "
		dc.b "SEGA GENESIS    "
; ---------------------------------------------------------------------------

BlueSpheresStartup:
		bsr.s	Test_Checksum
		move.b	d4,(Blue_spheres_header_flag).w
		bsr.w	Init_VDP
		bsr.w	SndDrvInit
		bsr.w	Init_Controllers
		move.b	#0,(Blue_spheres_menu_flag).w
		move.b	#$2C,(Game_mode).w
		bra.w	GameLoop
	endif
