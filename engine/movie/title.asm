_TitleScreen:
	call ClearBGPalettes
	call ClearSprites
	call ClearTilemap

; Turn BG Map update off
	xor a
	ldh [hBGMapMode], a
	ld [wTitleDogFrame], a

; Reset timing variables
	ld hl, wJumptableIndex
	ld [hli], a ; wJumptableIndex
	ld [hli], a ; wTitleScreenSelectedOption
	ld [hli], a ; wTitleScreenTimer
	ld [hl], a  ; wTitleScreenTimer + 1

; Turn LCD off
	call DisableLCD

; VRAM bank 1
	ld a, 1
	ldh [rVBK], a

; Decompress running Suicune gfx
	; ld hl, TitleSuicuneGFX
	; ld de, vTiles1
	; call Decompress

; Clear screen palettes
	hlbgcoord 0, 0
	ld bc, 20 * BG_MAP_WIDTH
	xor a
	call ByteFill

; Fill tile palettes:

; BG Map 1:

; line 0 (copyright)
	hlbgcoord 0, 0, vBGMap1
	ld bc, BG_MAP_WIDTH
	ld a, 7 ; palette
	call ByteFill

; BG Map 0:

; Apply logo gradient:

; lines 3-4
	hlbgcoord 0, 3
	ld bc, 2 * BG_MAP_WIDTH
	ld a, 2
	call ByteFill
; line 5
	hlbgcoord 0, 5
	ld bc, BG_MAP_WIDTH
	ld a, 3
	call ByteFill
; line 6
	hlbgcoord 0, 6
	ld bc, BG_MAP_WIDTH
	ld a, 4
	call ByteFill
; lines 7-11
	hlbgcoord 0, 7
	ld bc, BG_MAP_WIDTH
	ld a, 5
	call ByteFill
; line 12
	hlbgcoord 0, 12
	ld bc, 7 * BG_MAP_WIDTH
	ld a, 6
	call ByteFill

; 'CRYSTAL VERSION'
	hlbgcoord 5, 9
	ld bc, 11 ; length of version text
	ld a, 1
	call ByteFill

; Suicune gfx
	; hlbgcoord 0, 12
	; ld bc, 6 * BG_MAP_WIDTH ; the rest of the screen
	; ld a, 0 | VRAM_BANK_1
	; call ByteFill

; Back to VRAM bank 0
	xor a
	ldh [rVBK], a

; Decompress logo
	ld hl, TitleLogoGFX
	ld de, vTiles1
	call Decompress

; Decompress background crystal
	ld hl, TitleCrystalGFX
	ld de, vTiles0
	call Decompress

; Clear screen tiles
	hlbgcoord 0, 0
	ld bc, 64 * BG_MAP_WIDTH
	ld a, " "
	call ByteFill
	
	lb bc, BANK(TitleDogGFX), 8 tiles
	ld de, TitleDogGFX
	ld hl, vTiles0
	call Get2bpp

; Draw Pokemon logo
	hlcoord 0, 3
	lb bc, 7, 20
	ld d, $80
	ld e, 20
	call DrawTitleGraphic

; Draw copyright text
	hlbgcoord 3, 0, vBGMap1
	lb bc, 1, 13
	ld d, $c
	ld e, 16
	call DrawTitleGraphic

; Initialize running Suicune?
	;ld d, $0
	;call LoadSuicuneFrame

; Initialize background crystal
	;call InitializeBackground

; Update palette colors
	ldh a, [rSVBK]
	push af
	ld a, BANK(wBGPals1)
	ldh [rSVBK], a

	ld hl, TitleScreenPalettes
	ld de, wBGPals1
	ld bc, 16 palettes
	call CopyBytes

	ld hl, TitleScreenPalettes
	ld de, wBGPals2
	ld bc, 16 palettes
	call CopyBytes

	pop af
	ldh [rSVBK], a

; LY/SCX trickery starts here

	ldh a, [rSVBK]
	push af
	ld a, BANK(wLYOverrides)
	ldh [rSVBK], a

; Make alternating lines come in from opposite sides

; (This part is actually totally pointless, you can't
;  see anything until these values are overwritten!)

	ld b, 80 / 2 ; alternate for 80 lines
	ld hl, wLYOverrides
.loop
; $00 is the middle position
	ld [hl], +112 ; coming from the left
	inc hl
	ld [hl], -112 ; coming from the right
	inc hl
	dec b
	jr nz, .loop

; Make sure the rest of the buffer is empty
	ld hl, wLYOverrides + 80
	xor a
	ld bc, wLYOverridesEnd - (wLYOverrides + 80)
	call ByteFill

; Let LCD Stat know we're messing around with SCX
	ld a, LOW(rSCX)
	ldh [hLCDCPointer], a

	pop af
	ldh [rSVBK], a

; Set sprite size to 8x8
	ldh a, [rLCDC]
	res rLCDC_SPRITE_SIZE, a
	ldh [rLCDC], a

	ld a, +112
	ldh [hSCX], a
	ld a, 8
	ldh [hSCY], a
	ld a, 7
	ldh [hWX], a
	ld a, -112
	ldh [hWY], a

	ld a, TRUE
	ldh [hCGBPalUpdate], a

; Update BG Map 0 (bank 0)
	ldh [hBGMapMode], a
	
; Reset audio
	call ChannelsOff
	call EnableLCD

; Play starting sound effect
	call SFXChannelsOff
	ld de, SFX_TITLE_SCREEN_ENTRANCE
	call PlaySFX

	ret

SuicuneFrameIterator:
	ret

LoadSuicuneFrame:
	ret
	
DrawTitleGraphic:
; input:
;   hl: draw location
;   b: height
;   c: width
;   d: tile to start drawing from
;   e: number of tiles to advance for each bgrows
.bgrows
	push de
	push bc
	push hl
.col
	ld a, d
	ld [hli], a
	inc d
	dec c
	jr nz, .col
	pop hl
	ld bc, SCREEN_WIDTH
	add hl, bc
	pop bc
	pop de
	ld a, e
	add d
	ld d, a
	dec b
	jr nz, .bgrows
	ret

InitializeBackground:
	ld hl, wShadowOAMSprite00
	ld d, -$22
	ld e, $0
	ld c, 5
.loop
	push bc
	call .InitColumn
	pop bc
	ld a, $10
	add d
	ld d, a
	dec c
	jr nz, .loop
	ret

.InitColumn:
	ld c, $6
	ld b, $40
.loop2
	ld a, d
	ld [hli], a ; y
	ld a, b
	ld [hli], a ; x
	add $8
	ld b, a
	ld a, e
	ld [hli], a ; tile id
	inc e
	inc e
	ld a, 0 | PRIORITY
	ld [hli], a ; attributes
	dec c
	jr nz, .loop2
	ret

AnimateTitleCrystal:
; Move the title screen crystal downward until it's fully visible

; Stop at y=6
; y is really from the bottom of the sprite, which is two tiles high
	ld hl, wShadowOAMSprite00YCoord
	ld a, [hl]
	cp 6 + 2 * TILE_WIDTH
	ret z

; Move all 30 parts of the crystal down by 2
	ld c, 30
.loop
	ld a, [hl]
	add 2
	ld [hli], a ; y
rept SPRITEOAMSTRUCT_LENGTH - 1
	inc hl
endr
	dec c
	jr nz, .loop

	ret

TitleLogoGFX:
INCBIN "gfx/title/logo.2bpp.lz"

TitleCrystalGFX:
INCBIN "gfx/title/crystal.2bpp.lz"

TitleDogGFX:
INCBIN "gfx/title/dog.2bpp"

TitleScreenPalettes:
INCLUDE "gfx/title/title.pal"
