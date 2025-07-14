.label screenClrOffset = 250
.const bankSize = pow(2,14)
.const VideoBankNo = 2
.const videoBankStart = bankSize*VideoBankNo 

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
     .label spritePtr1 = 2040
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
     .label PixelOffsetBit2 = 4 
     .label PixelOffsetBit1 = 2 
     .label PixelOffsetBit0 = 1 
}

     .label bitmapScrBase = $2000

     .label color_ram = $d800

     clearScreen:
     ldx #screenClrOffset
     lda #petscii.blank
!loop:
    sta scr_ram,x 
    sta scr_ram+screenClrOffset,x 
    sta scr_ram+(screenClrOffset*2),x 
    sta scr_ram+(screenClrOffset*3),x 
    dex 
    bne !loop-
    rts

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
     lda #43
!loop:
     sta (zeropage),y
     dey 
     bne !loop-
     dex
     inc zeropage+1 
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
     ora #bankNo
     sta CIA.memoryBank

}


.macro selectScreenBank(bankNo) {
     lda VIC.Char_BankCtrl 
     and #$0f
     ora #(1<<bankNo)
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

.struct Point {x,y}

.struct Sprite {
     x,
     y,
     ptr
}