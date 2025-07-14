.import source "constants.asm"
.import source "macros.asm"
.import source "graphics.asm"
.import source "input.asm"
.import source "strings.asm"
.function calcSpritePtr(address) {
    .return ((address-videoBankStart)/64)
}
.enum  {
   LEFT,RIGHT,UP,DOWN 
}
.label stepSize = 32
*=$801
    .byte $0c,$08,$e2,$07,$9e,$20,$32,$30,$36,$32,$00,$00,$00
    lda #0 
    multiplyByRow(12)
    multiplyBy8(32)
    finalValue()
.break
    selectVideoBank(VideoBankNo)  
    clearScreen()
    setupRasterIRQ(customIRQ)
    toggleBitmap(true) 
    toggleBitmapBank(true) 
    clearBitmap()
    .for(var i =0; i < 30; i++) {
        setTile(i,0)
    }
    lda #255
    sta SpriteActiveReg 
    lda  #(calcSpritePtr(Sprite1))
    sta spritePtr1 
    .for(var x = 1; x < 8; x++) {
        setSpritePtr(x,calcSpritePtr(Sprite1))
        setValue(Sprite0AccuX+x*5,$30+x*10)
        setValue(Sprite0AccuY+x*5,$30+x*20)
        setSpriteMultiColor(x)
        setSpriteColor(x,x)
        setSpriteViaAddress(x,Sprite0AccuX+x*5,Sprite0AccuY+x*5);
    }
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

.macro multiplyBy8(value) {
    lda #0
    sta zeropage2 
    lda #value
    sta zeropage2+1
    clc 
    .for(var k = 0; k < 3; k++) { 
        asl zeropage2+1 
        rol zeropage2 
        
    }

}


.macro multiplyByRow(y) {
    lda #0 
    sta zeropage
    sta zeropage2 
    lda #y 
    sta zeropage+1
    sta zeropage2+1 
    clc 
    .for(var k =0; k < 8; k++) {
        asl zeropage+1 
        rol zeropage 
    }
    clc
    .for(var k =0; k < 6; k++) {
        asl zeropage2+1 
        rol zeropage2 
    }
    clc 
    lda zeropage+1 
    adc zeropage2+1 
    sta zeropage+1 
    lda zeropage 
    adc zeropage2 
    sta zeropage 

}

.macro finalValue() {
    clc 
    lda zeropage+1 
    adc zeropage2+1 
    sta zeropage+1 
    lda zeropage 
    adc zeropage2 
    sta zeropage 
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
.byte $00,$00,$00,$00,$00,$00,$00,$87

Tiles:
    .byte $41,$22,$14,$8,$14,$22,$41,$80
.macro turnOffKernal() {
    lda #$35
    sta $1
}

