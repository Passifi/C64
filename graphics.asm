.label screenClrOffset = 250
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
.namespace VIC {
     .label SpriteReg = $d01c
     .label Sprite1XLow = $d000
     .label Sprite1Y = $d001
     .label ActiveSpriteRegister = $d015
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
}

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

 