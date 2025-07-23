.import source "constants.asm"
.import source "macros.asm"
.import source "graphics.asm"
.import source "input.asm"
.import source "strings.asm"
.import source "sound.asm"

.function calcSpritePtr(address) {
    .return ((address-videoBankStart)/64)
}
.enum  {
   LEFT,RIGHT,UP,DOWN 
}
.label stepSize = 32
*=$801
    .byte $0c,$08,$e2,$07,$9e,$20,$32,$30,$36,$32,$00,$00,$00
setup:
    setupRasterIRQ(customIRQ)
    lda #<Tiles+1
    sta zeropage2 
    lda #>Tiles+1 
    sta zeropage2+1
    clearBitmap()
    clearScreen(calculateColorPair(colors.black,colors.grey))
    jsr loadTileMap
    selectVideoBank(VideoBankNo)  
    toggleBitmap(true) 
    toggleBitmapBank(true) 
    toggleMultiColor(true)
    initializeSprites()
   
setupend:    
!main:
    jmp !main-

customIRQ:
        lda VIC.IRQStatus 
        sta VIC.IRQStatus
        lda VIC.RasterlineInterrupt 
        cmp #250 
        bne !end+ 
        jsr processInput 
        jsr moveSprite
        jsr setSprites
    !end:
    jmp $ea31
     
setSprites:
    .for(var i = 0; i < 8; i++) {
        setSpriteViaAddress(i,Sprite0AccuX+i*5,Sprite0AccuY+i*5)
    }
    rts 

moveSprite:
    moveObject(PlayerXAccu,RIGHT,stepSize)
   .for(var i =0; i < 7; i++)
   { 
    moveObject(Sprite1AccuX+i*5,RIGHT, 220+i*2)
   }
    rts
nmi:
    PushRegister()
    lda $dd0d // confirm IRQ
    sta $dd0d
!exit:
    PullRegisters()
    rti

.macro initializeSprites() {
    lda #$ff
    sta SpriteActiveReg  
    .for(var x = 1; x < 8; x++) {
        setSpritePtr(x,calcSpritePtr(Sprite1))
        setValue(Sprite0AccuX+x*5,$30+x*10)
        setValue(Sprite0AccuY+x*5,$30+x*20)
        setSpriteMultiColor(x)
        setSpriteColor(x,x)
        setSpriteViaAddress(x,Sprite0AccuX+x*5,Sprite0AccuY+x*5);
    }
    setSpriteAuxiliaryColor(0,colors.white)
    setSpriteAuxiliaryColor(1,colors.black)
}

.macro setValue(address,value) {
    lda #value 
    sta address
} 
.namespace JoyStick{
    .label Up = 1
    .label Down = 2
    .label Left = 4
    .label Right = 8 
    .label Fire = 16 
}

processInput:
    lda $DC00 
    sta Input
    lda #JoyStick.Up
    bit Input 
    bne DownTest 
DownTest:
    lda #JoyStick.Down
    bit Input 
    bne RightTest
RightTest: 
    lda #JoyStick.Right
    bit Input
    bne leftTest
.break
    moveObject(PlayerXAccu,RIGHT,120) 
    jmp !end+ 
leftTest:  
    lda #JoyStick.Right
    bit Input
    bne !end+
    moveObject(PlayerXAccu,LEFT,120) 
!end:
    rts

Input:
    .byte $01

Timer:
    .word 00
PlayerXAccu:
    .word 0
    .byte 0
PlayerYAccu:
    .word 0
PlayerPosX:
    .word 00
PlayerPosY:
    .byte 00
Sprite0AccuX:
        .word 0
        .byte 0
Sprite0AccuY:
        .word 0
Sprite1AccuX:
        .word 0
        .byte 0
Sprite1AccuY:
        .word 0
Sprite2AccuX:
        .word 0
        .byte 0
Sprite2AccuY:
        .word 0
Sprite3AccuX:
        .word 0
        .byte 0
Sprite3AccuY:
        .word 0
Sprite4AccuX:
        .word 0
        .byte 0
Sprite4AccuY:
        .word 0
Sprite5AccuX:
        .word 0
        .byte 0
Sprite5AccuY:
        .word 0
Sprite6AccuX:
        .word 0
        .byte 0
Sprite6AccuY:
        .word 0
Sprite7AccuX:
        .word 0
        .byte 0
Sprite7AccuY:
        .word 0
msg:
.text "hello from myself, and jesus"        
msgEnd:
#define TileAddress
SpriteTable:
    .for(var x = 0; x < 8; x++) {
        .word $ff33
        .byte $ff
        .byte $ff
    }
SpriteTableEnd:
.macro addWord(address,value) {
    clc 
    lda address+1 
    adc #value 
    sta address+1
    lda address 
    adc #0 
    sta address
}
.macro addLong(address,value) {
    clc 
    lda address+2
    adc #value 
    sta address+2 
    lda address+1 
    adc #0
    sta address+1 
    lda address
    adc #0
    sta address
}
.macro subWord(address,value) {
    sec 
    lda address+1 
    sbc #value 
    sta address+1
    lda address 
    sbc #0
    sta address 
}
.macro moveObject(address,x,value) {
    .if( x == RIGHT) {
        addLong(address,value)
        lda address 
        cmp #0
        beq !end+
        lda address+1
        cmp #60
        bcc !end+
        lda #0
        sta address
        sta address+1
    } 
    .if(x == LEFT) {
        addWord(address,value)
    }
    .if(x == UP) {
        subWord(address+2,value)
    }
    .if(x == DOWN) {
        addWord(address+2,value)
    }
!end:
}
setTileAt:
    // x,y arethe position
    lda #0
    cpx #0
    beq staY
    sec
!loop:
    rol 
    dex 
    bne !loop-
staY:
    sta zeropage
    lda #<bitmapScrBase 
    adc zeropage 
    sta zeropage  
    lda #>bitmapScrBase
    sta zeropage+1
    rts

*=videoBankStart+$1000
Sprite1:
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $28,$00,$0f,$ff,$fc,$0f,$ff,$fc
.byte $fa,$aa,$a0,$39,$59,$58,$39,$d9
.byte $78,$f9,$f9,$f8,$ca,$aa,$a8,$0a
.byte $aa,$a8,$0a,$aa,$a8,$02,$aa,$a0
.byte $02,$95,$a0,$00,$aa,$80,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$87 // throwway byte
.byte $0,$0,$0,$0,$0,$0,$0,$0
.byte $0,$0,$0,$0,$0,$0,$0,$0
.byte $3f,$ff,$f0,$3f,$ff,$f0,$0,$28
.byte $67,$6c,$25,$65,$6c,$a,$aa,$af
.byte $a0,$2a,$aa,$a3,$2f,$6f,$6f,$2d
.byte $a,$aa,$80,$2a,$aa,$a0,$2a,$aa
.byte $0,$0,$2,$aa,$0,$a,$56,$80
.byte $d2,$0,$0,$0,$0,$0,$0,$0
TileAddress:
Tiles:
    .byte $41,$22,$14,$8,$14,$22,$41,$80
    .byte $ff,$22,$22,$22,$22,$22,$22,$22 
    .byte $3f,$ff,$f0,$3f,$ff,$f0,$0,$28
    .byte $3d,$22,$22,$22,$22,$22,$22,$22 
    .byte $aa,$a8,$0a,$aa,$a8,$02,$aa,$a0
    .byte $ff,$22,$22,$22,$22,$22,$22,$22 

Tilemap:
    .byte 0,0,0,0,0,0,0,0
    .byte 1,1,1,1,1,1,1,1
        .byte 0,0,0,0,0,0,0,0
    .byte 1,1,1,1,1,1,1,1
    .byte 3,2,1,4,4,0,0,4
    .byte 0,0,0,0,0,0,0,0
 .byte 0,0,0,0,0,0,0,0
    .byte 1,1,1,1,1,1,1,1
    .byte 3,2,1,4,4,0,0,4
    .byte 0,0,0,0,0,0,0,0
 .byte 0,0,0,0,0,0,0,0
    .byte 1,1,1,1,1,1,1,1
    .byte 3,2,1,4,4,0,0,4
    .byte 0,0,0,0,0,0,0,0
 .byte 0,0,0,0,0,0,0,0
    .byte 1,1,1,1,1,1,1,1
    .byte 3,2,1,4,4,0,0,4
    .byte 0,0,0,0,0,0,0,0
 .byte 3,2,1,4,4,0,0,4
    .byte 0,0,0,0,0,0,0,0
TilemapEnd:

.macro turnOffKernal() {
    lda #$35
    sta $1
}

