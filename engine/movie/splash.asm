SplashScreen:
; Play the copyright screen and GameFreak Presents sequence.
; Return carry if user cancels animation by pressing a button.

; Reinitialize everything
	ld de, MUSIC_NONE
	call PlayMusic
	call ClearBGPalettes
	call ClearTilemap
	ld a, HIGH(vBGMap0)
	ldh [hBGMapAddress + 1], a
	xor a ; LOW(vBGMap0)
	ldh [hBGMapAddress], a
	ldh [hJoyDown], a
	ldh [hSCX], a
	ldh [hSCY], a
	ld a, SCREEN_HEIGHT_PX
	ldh [hWY], a
	call WaitBGMap
	ld b, SCGB_GAMEFREAK_LOGO
	call GetSGBLayout
	call SetDefaultBGPAndOBP
	ld c, 10
	call DelayFrames

; Draw copyright screen
	callfar Copyright
	call WaitBGMap
	ld c, 100
	call DelayFrames
	call ClearTilemap

; Stop here if not in GBC mode
	farcall GBCOnlyScreen

; Stop here if MBC30 check failed
	farcall MBC30Screen

; Play GameFreak logo animation
	farcall CrystalmoonIntroScene

.finish
	call GameFreakPresentsEnd
	and a
	ret

GameFreakPresentsInit:
GameFreakPresentsScene:
.scenes
GameFreakPresents_NextScene:
GameFreakPresents_WaitSpriteAnim:
GameFreakPresents_PlaceGameFreak:
.PlaceGameFreak:
.game_freak
.end
GameFreakPresents_PlacePresents:
.place_presents
.presents
.end
GameFreakPresents_WaitForTimer:
.finish
GameFreakLogoSpriteAnim:
.scenes:
GameFreakLogo_Init:
GameFreakLogo_Bounce:
.no_negative
.done
GameFreakLogo_Ditto:
.start_transform
GameFreakLogo_Transform:
.done
GameFreakLogo_Done:
GameFreakDittoPaletteFade:
GameFreakLogoGFX:
	ret

GameFreakPresentsEnd:
	farcall ClearSpriteAnims
	call ClearTilemap
	call ClearSprites
	ld c, 16
	call DelayFrames
	ret
