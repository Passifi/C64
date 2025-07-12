.import source "constants.asm"
.import source "macros.asm"
.import source "graphics.asm"
.import source "input.asm"
.import source "strings.asm"
.function calcSpritePtr(address) {
    .return (address/64)
}
.enum  {
   LEFT,RIGHT,UP,DOWN 
}
.label stepSize = 32
*=$801
    .byte $0c,$08,$e2,$07,$9e,$20,$32,$30,$36,$32,$00,$00,$00
    
    nop 
    nop
    nop 
    setupRasterIRQ(customIRQ)
    jsr clearScreen 
    setCursorPosition(520)
    stringCopyAt(msg,(msgEnd-msg)) 
    jsr setupNMI
    lda #255
    sta SpriteActiveReg 
    lda  #($3200/64)
    sta spritePtr1 
    .for(var x = 1; x < 8; x++) {
        setSpritePtr(x,calcSpritePtr(Sprite1))
        setValue(Sprite0AccuX+x*5,$30+x*10)
        setValue(Sprite0AccuY+x*5,$30+x*20)
        setSpriteMultiColor(x)
        setSpriteColor(x,x)
        setSpriteViaAddress(x,Sprite0AccuX+x*5,Sprite0AccuY+x*5);
    }
    toggleBitmap(true)
    lda #120
    sta Sprite1XLow 
    sta Sprite1Y
    setSpriteMultiColor(0)
    setSpriteColor(0,colors.orange)
    setSpriteAuxiliaryColor(0,colors.white)
    setSpriteAuxiliaryColor(1,colors.black)
    
!loop:
    jmp !loop-

customIRQ:
    
    lda VIC.IRQStatus 
    sta VIC.IRQStatus
    lda VIC.RasterlineInterrupt 
    cmp #250 
    bne !end+ 
    jsr moveSprite
    jsr setSprites
!end:
    jmp $ea31
     
setSprites:
    .for(var i = 0; i < 8; i++) {
        setSpriteViaAddress(i,Sprite0AccuX+i*5,Sprite0AccuY+i*5)

    }
    rts 
setupNMI:
    ldx $dd0d // CIA-2
    lda #%01111111 // deactivate all interrupts 
    sta $dd0d 
    lda #<nmi 
    sta $0318 
    lda #>nmi 
    sta $0319
    lda #$ff 
    sta $dd04 // cia timer 
    lda #$1
    sta $dd05 // cia timer high byte
    lda #1 // start timer in cia-2 
    sta $dd0e 
    txa 
    ora #%10000001
    sta $dd0d 
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

.macro setValue(address,value) {
    lda #value 
    sta address
} 

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

*=$3200
Sprite1:
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$00
.byte $28,$00,$0f,$ff,$fc,$0f,$ff,$fc
.byte $fa,$aa,$a0,$39,$59,$58,$39,$d9
.byte $78,$f9,$f9,$f8,$ca,$aa,$a8,$0a
.byte $aa,$a8,$0a,$aa,$a8,$02,$aa,$a0
.byte $02,$95,$a0,$00,$aa,$80,$00,$00
.byte $00,$00,$00,$00,$00,$00,$00,$87

.byte $00,$ff,$c0,$00,$ea,$b0,$03,$ea
.byte $b0,$0f,$aa,$b0,$0e,$aa,$b0,$3f
.byte $6d,$bc,$3b,$6d,$ac,$3b,$ad,$ac
.byte $3a,$aa,$bc,$3a,$aa,$b0,$3e,$aa
.byte $b0,$0e,$6a,$c0,$0f,$56,$c0,$0f
.byte $de,$c0,$0e,$fe,$c0,$0e,$aa,$c0
.byte $0f,$af,$00,$0f,$ff,$00,$00,$00




.byte $0f,$fc,$00,$38,$06,$00,$20,$03
.byte $00,$20,$01,$00,$27,$01,$80,$27
.byte $8e,$80,$37,$9e,$80,$12,$1e,$c0
.byte $10,$0e,$40,$10,$06,$40,$18,$00
.byte $40,$08,$40,$40,$0f,$c0,$40,$06
.byte $c0,$c0,$02,$60,$80,$02,$31,$80
.byte $02,$3f,$00,$03,$2c,$00,$01,$e0
.byte $00,$00,$00,$00,$00,$00,$00,$01