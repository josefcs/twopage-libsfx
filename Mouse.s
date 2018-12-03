
.include "libSFX.i"
.include "OAM.i"

;VRAM destination addresses
VRAM_MAP_LOC     = $1000
VRAM_TILES_LOC   = $8000

Main:
        ;Init shadow oam
        OAM_init shadow_oam, 0, 0, 0

        ;Decompress graphics and upload to VRAM
        LZ4_decompress Map, EXRAM, y
        VRAM_memcpy VRAM_MAP_LOC, EXRAM, y

        LZ4_decompress Tiles, EXRAM, y
        VRAM_memcpy VRAM_TILES_LOC, EXRAM, y

        CGRAM_memcpy 0, Palette, sizeof_Palette

        ;Set up screen mode
        lda     #bgmode(BG_MODE_1, BG3_PRIO_NORMAL, BG_SIZE_8X8, BG_SIZE_8X8, BG_SIZE_8X8, BG_SIZE_8X8)
        sta     BGMODE
        lda     #bgsc(VRAM_MAP_LOC, SC_SIZE_32X32)
        sta     BG1SC
        ldx     #bgnba(VRAM_TILES_LOC, 0, 0, 0)
        stx     BG12NBA
        sta     OBJSEL
        lda     #tm(ON, OFF, OFF, OFF, ON)
        sta     TM

        stz $19 ; init to second screen

        ;Set VBlank handler
        VBL_set VBL

        ;Turn on screen
        lda     #inidisp(ON, DISP_BRIGHTNESS_MAX)
        sta     SFX_inidisp
        VBL_on

GAME_LOOP:       

        lda $19
        cmp #$00        ; only when 2nd screen was not yet loaded, check for joy
        bne GAME_LOOP

        lda $4219   ; read joypad
        and #$10    ; check if the start button was pressed
        cmp #$10
        bne GAME_LOOP

        lda #$01 ; set 2nd screen status to loaded
        sta $19

        VBL_off

        lda     #%10000000  ; Force VBlank by turning off the screen.
        sta     $2100

        LZ4_decompress Scr2Map, EXRAM, y
        VRAM_memcpy VRAM_MAP_LOC, EXRAM, y

        LZ4_decompress Scr2Tile, EXRAM, y
        VRAM_memcpy VRAM_TILES_LOC, EXRAM, y

        CGRAM_memcpy 0, Scr2Pal, sizeof_Scr2Pal

        lda     #%00001111  ; End VBlank, setting brightness to 15 (100%).
        sta     $2100

        VBL_on
        
        jmp GAME_LOOP

;-------------------------------------------------------------------------------
VBL:
        rtl
; end VBL

;-------------------------------------------------------------------------------
.segment "LORAM"
shadow_oam:     .res 512+32

;-------------------------------------------------------------------------------

;Import graphics
.segment "RODATA"
incbin  Palette,        "Data/first.png.palette"
incbin  Tiles,          "Data/first.png.tiles.lz4"
incbin  Map,            "Data/first.png.map.lz4"

incbin  Scr2Pal,       "Data/second.png.palette"
incbin  Scr2Tile,      "Data/second.png.tiles.lz4"
incbin  Scr2Map,       "Data/second.png.map.lz4"