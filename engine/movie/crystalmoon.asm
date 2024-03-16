CrystalmoonIntroScene::
	call ClearBGPalettes
	call ClearSprites
	call ClearTilemap
	
	; Turn BG Map update off
	xor a
	ldh [hBGMapMode], a
	
	; Turn LCD off
	call DisableLCD
	
; VRAM bank 1
	ld a, 1
	ldh [rVBK], a
	
; Clear screen palettes
	hlbgcoord 0, 0
	ld bc, 20 * BG_MAP_WIDTH
	xor a
	call ByteFill
	
DEF LOGO_POSITION EQU 6
	
; Palettes
	hlbgcoord 0, LOGO_POSITION + 0
	ld bc, 2 * BG_MAP_WIDTH
	ld a, 5
	call ByteFill
	
	hlbgcoord 0, LOGO_POSITION + 1
	ld bc, 2 * BG_MAP_WIDTH
	ld a, 4
	call ByteFill
	
	hlbgcoord 0, LOGO_POSITION + 2
	ld bc, 2 * BG_MAP_WIDTH
	ld a, 3
	call ByteFill
	
	hlbgcoord 0, LOGO_POSITION + 3

	ld bc, 2 * BG_MAP_WIDTH
	ld a, 2
	call ByteFill
	
	hlbgcoord 0, LOGO_POSITION + 4

	ld bc, 2 * BG_MAP_WIDTH
	ld a, 1
	call ByteFill
	
	hlbgcoord 0, LOGO_POSITION + 5

	ld bc, 2 * BG_MAP_WIDTH
	xor a
	call ByteFill

	pop af
	ldh [rSVBK], a
	
; Back to VRAM bank 0
	xor a
	ldh [rVBK], a
	
; Update palette colors
	ldh a, [rSVBK]
	push af
	ld a, BANK(wBGPals1)
	ldh [rSVBK], a

	ld hl, CrystalmoonScreenPalettes
	ld de, wBGPals1
	ld bc, 16 palettes
	call CopyBytes

	ld hl, CrystalmoonScreenPalettes
	ld de, wBGPals2
	ld bc, 16 palettes
	call CopyBytes

	pop af
	ldh [rSVBK], a
	
	lb bc, BANK(CrystalmoonScreenGFX), (CrystalmoonScreenPalettes - CrystalmoonScreenGFX) / 8
	ld de, CrystalmoonScreenGFX
	ld hl, vTiles1
	call Get2bpp
	
	hlcoord 4, LOGO_POSITION
	lb bc, 5, 13
	lb de, $80, 13
	call DrawGraphic
	
	call EnableLCD
	
	ld a, TRUE
	ldh [hCGBPalUpdate], a
	ldh [hBGMapMode], a
	
	ld c, 90 ; frames
	call DelayFrames 
	farcall StartTitleScreen
	ret
	
CrystalmoonScreenGFX:
INCBIN "gfx/title/crystalmoon.2bpp"

CrystalmoonScreenPalettes:
INCLUDE "gfx/title/crystalmoon.pal"

	