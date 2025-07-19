.label screenClrOffset = 250
.const bankSize = pow(2,14)
.const VideoBankNo = 1
.const videoBankStart = bankSize*VideoBankNo 
#if !TileAddress 
Tiles:
Tilemap:
TilemapEnd:
#endif
.namespace colors {
    .label black         = 0
    .label white         = 1
    .label red           = 2
    .label cyan          = 3
    .label purple        = 4
    .label green         = 5
    .label blue          = 6
    .label yellow        = 7
    .label orange        = 8
    .label brown         = 9
    .label light_red     = 10
    .label dark_grey     = 11
    .label grey          = 12
    .label light_green   = 13
    .label light_blue    = 14
    .label light_grey    = 15
}

.namespace CIA {
     .label ctrlOutput = $DD02
     .label memoryBank = $DD00
}
.namespace VIC {
     .label SpriteReg = $d01c
     .label Sprite1XLow = $d000
     .label Sprite1Y = $d001
     .label ActiveSpriteRegister = $d015
     .label CtrlReg1 = $d011
     .label RasterlineInterrupt = $d012
     .label CtrlReg2 = $d016 
     .label Char_BankCtrl = $d018
     .label IRQStatus = $d019
     .label frameColor = $d020
     .label backgroundColor = $d021 
     .label SpriteAuxiliaryColor1 = $d025
     .label SpriteAuxiliaryColor2 = $d026 
     .label Sprite1Color = $d027 
     .label Sprite2Color = $d028 
     .label Sprite3Color = $d029
     .label Sprite4Color = $d02A 
     .label Sprite5Color = $d02B
     .label Sprite6Color = $d02C
     .label Sprite7Color = $d02D
     .label Sprite8Color = $d02E 
     .label MulticolorCtrl = $d01c
     .label SpriteXHighbit = $d010
     .label spritePtr1 = videoBankStart+2040
     .label spritePtr2 = 2041
     .label spritePtr3 = 2042
     .label spritePtr4 = 2043
     .label spritePtr5 = 2044
     .label spritePtr6 = 2045
     .label spritePtr7 = 2046
     .label spritePtr8 = 2047
     }

.namespace VICCtrl1 {
     .label Bit9RasterIRQ = 128
     .label ExtColorMode = 64
     .label Bitmapmode = 32 
     .label ShowScreen = 16
     .label LineMode24_25 = 8  
}

.namespace VICCtrl2 {
     .label MultiColor = 16
     .label ColumnMode = 8
     .label PixelOffsetBit2 = 4 
     .label PixelOffsetBit1 = 2 
     .label PixelOffsetBit0 = 1 
}

     .label bitmapScrBase = $6000

     .label color_ram = $d800
.function calculateColorPair(color1, color2 ) {
     .return (color1 << 4) | (color2&$0f) 
}


.macro clearScreen(value) {
     sei 
     ldx #screenClrOffset
     lda #value
!loop:
    sta videoBankStart+scr_ram,x 
    sta videoBankStart+scr_ram+screenClrOffset,x 
    sta videoBankStart+scr_ram+(screenClrOffset*2),x 
    sta videoBankStart+scr_ram+(screenClrOffset*3),x 
    dex 
    bne !loop-
    cli
}

.macro toggle38columns() {
     lda VIC.CtrlReg2 
     and #(~VICCtrl2.ColumnMode) 
     ora #VICCtrl2.ColumnMode 
     sta VIC.CtrlReg2 
}
XPos:
     .byte $0
.macro scrollRight() {
     lda VIC.CtrlReg2
     and #(~7)
     ora XPos 
     sta VIC.CtrlReg2
     inc XPos 
     lda XPos 
     cmp #7
     bne !end+
     lda #0 
     sta XPos 
!end:
}

.macro activateSprite(no) {
     lda VIC.ActiveSpriteRegister 
     ora #(1<<no) 
     sta VIC.ActiveSpriteRegister
}
.macro clearBitmap() {
     lda #<bitmapScrBase
     sta zeropage
     lda #>bitmapScrBase
     sta zeropage+1 
     ldx #32
     ldy #0
     tya
!loop:
     sta (zeropage),y
     dey 
     bne !loop-
     inc zeropage+1
     dex
     bne !loop-
}
.macro setColor(x,y,color) {
     .var result = x + y*40
     lda #color
     sta color_ram+result
}


.macro deactivateSprite(no) {
     lda VIC.ActiveSpriteRegister 
     and #(~(1<<no)) 
     sta VIC.ActiveSpriteRegister
}

.macro setSpriteColor(no, color) {
          lda #color 
          sta VIC.Sprite1Color+no
}

.macro toggleMultiColor(value) {
     
     lda VIC.CtrlReg2 
     .if(value) {
     ora #(VICCtrl2.MultiColor)
     }
     else {

          and #(~VICCtrl2.MultiColor)

     }
     sta VIC.CtrlReg2
}

.macro setSpriteMultiColor(no) {
     lda VIC.MulticolorCtrl
     ora #(1<<no)
     sta VIC.MulticolorCtrl
}

.macro setSpriteAuxiliaryColor(no,color) {
     .if (no == 0) {
          lda #color 
          sta VIC.SpriteAuxiliaryColor1
     }
     else {
          lda #color 
          sta VIC.SpriteAuxiliaryColor2
     }
}
// zeropage should contain the right memory address
.macro setTileWithZeropage(tileAddress) {
     lda #<tileAddress 
     sta zeropage2 
     lda #>tileAddress
     sta zeropage2+1
     clc
     lda #<bitmapScrBase
     adc zeropage 
     sta zeropage 
     lda #>bitmapScrBase 
     adc zeropage+1 
     sta zeropage+1
     ldy #7
!loop:
     lda (zeropage2),y 
     sta (zeropage),y 
     dey 
     bpl !loop-

}

.macro setTile(x,y) {
    .var offset = x*8+y*40*8 
     .for(var i = 0; i < 8; i++) {
          lda 0+i 
          sta bitmapScrBase+offset+i
     }
}


.macro setSpritePtr(no, ptr) {
    lda #ptr
    sta VIC.spritePtr1+no
}

.macro setSprite(no, x,y ) {
    lda #<x 
    sta VIC.Sprite1XLow+no*2 
    lda #>x
    cmp #0 
    bcc !setHighBitLow+
    lda VIC.SpriteXHighbit 
    ora #(1<<no)
    sta VIC.SpriteXHighbit
    jmp !setYPos+  
!setHighBitLow:
    lda VIC.SpriteXHighbit 
    and #~(1<<no)
    sta VIC.SpriteXHighbit
!setYPos:
    lda #y
    sta VIC.Sprite1Y+no*2 
}

.macro setSpriteViaAddress(no,xPtr, yPtr) {
     lda xPtr+1 
     sta VIC.Sprite1XLow+no*2
     lda xPtr
     cmp #0
     beq !setHighZero+
     lda VIC.SpriteXHighbit
     ora #(1<<no)
     sta VIC.SpriteXHighbit
     jmp !continue+
!setHighZero:
     lda VIC.SpriteXHighbit
     and #(~(1<<no)) 
     sta VIC.SpriteXHighbit
!continue:
     lda yPtr 
     sta VIC.Sprite1Y+no*2
}

.macro toggleBitmap(value) {
     .if(value) { 
     lda VIC.CtrlReg1
     ora #VICCtrl1.Bitmapmode
     sta VIC.CtrlReg1 
     }
     else {
          lda VIC.CtrlReg1 
          and #(~(VICCtrl1.Bitmapmode))
          sta VIC.CtrlReg1 
     }
}
.macro ACKRaster() {
     lda VIC.IRQStatus 
     sta VIC.IRQStatus
}

.macro setupRasterIRQ(customIrqAddress) {
     sei 
     lda #<customIrqAddress
     sta StockIRQVector 
     lda #>customIrqAddress
     sta StockIRQVector+1 
     lda #250
     sta VIC.RasterlineInterrupt 
     lda VIC.CtrlReg1
     and #(~VICCtrl1.Bit9RasterIRQ)
     sta  VIC.CtrlReg1
     lda $d01a //actiavte VIC remember to name this one 
     ora #%1 
     sta $d01a 
     cli 
}

.macro selectVideoBank(bankNo) {
     .assert "legal Bank", bankNo < 4, true 
     lda CIA.ctrlOutput
     ora #3 
     sta CIA.ctrlOutput
     lda CIA.memoryBank 
     and #%11111100 
     ora #($3&(~bankNo))
     sta CIA.memoryBank

}


.macro selectScreenBank(bankNo) {
     lda VIC.Char_BankCtrl 
     and #$0f
     ora #(1<<bankNo)
     sta VIC.Char_BankCtrl
}

.macro toggleBitmapBank(switch) {
     lda VIC.Char_BankCtrl
     and #%11110111
     .if(switch) {
          ora #8
     }
     sta VIC.Char_BankCtrl
}

.macro setCharRomPosition(bankNo) {
     lda VIC.Char_BankCtrl
     and $f0 
     ora #(1<<bankNo)
     sta VIC.Char_BankCtrl
}


.macro moveSprite(no,x,y) {

}

.macro multiplyBy8(value) {
    lda #0
    sta zeropage2+1 
    lda #value
    sta zeropage2
    clc 
    .for(var k = 0; k < 3; k++) { 
        asl zeropage2 
        rol zeropage2+1 
        
    }

}


.macro multiplyByRow(y) {
    lda #0 
    sta zeropage+1
    sta zeropage2+1
    lda #y 
    sta zeropage
    sta zeropage2 
    clc 
    .for(var k =0; k < 8; k++) {
        asl zeropage 
        rol zeropage+1 
    }
    clc
    .for(var k =0; k < 6; k++) {
        asl zeropage2 
        rol zeropage2+1 
    }
    clc 
    lda zeropage
    adc zeropage2 
    sta zeropage 
    lda zeropage+1 
    adc zeropage2+1 
    sta zeropage+1 

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
.label tileAddress = $fd
.macro writeCurrentTile() {
    ldy #7
!loop2:
     lda (tileAddress),y
     sta (zeropage),y
     dey
     bpl !loop2-
} 
.label counterByte = $02
fillBitmap: // expects tileadress in zeropage2 
     lda #<bitmapScrBase
     sta zeropage
     lda #>bitmapScrBase
     sta zeropage+1
     ldy #8
     ldx #255
!loopPrepare: 
     tya
     pha
!loop: 
     writeCurrentTile()
     clc
     lda #8 
     adc zeropage 
     sta zeropage 
     bcc !next+ 
     inc zeropage+1  
!next:
     dex
     bne !loop-
     pla 
     tay
     dey 
     bne !loopPrepare- 
     rts 
.const tilemapLength = TilemapEnd - Tilemap
.label bitmapzp_low = $02
.label bitmapzp_high = $03
.label tileZeropage = zeropage2
.label TilemapZeropage = zeropage

loadTileMap:
     loadAddress(bitmapScrBase,bitmapzp_low)
     loadAddress(Tilemap,TilemapZeropage)
     loadAddress(Tiles,tileZeropage) 
     ldx #0
!loop:
     txa
     tay
     lda (TilemapZeropage),y
     clc
     adc #<Tiles 
     sta tileZeropage
     ldy #64
!tileLoop:
          lda (tileZeropage),y 
          sta (bitmapzp_low),y 
          dey 
          bpl !tileLoop-
     clc 
     lda bitmapzp_low
     adc #64
     sta bitmapzp_low
     bcc !noCarry+
     inc bitmapzp_high
!noCarry: 
     inx
     cpx #tilemapLength 
     bne !loop-
     rts

BitmapAddress:
     .word $00