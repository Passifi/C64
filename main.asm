.import source "constants.asm"
.import source "macros.asm"
.import source "graphics.asm"
.import source "input.asm"
.import source "strings.asm"

*=$801
    .byte $0c,$08,$e2,$07,$9e,$20,$32,$30,$36,$32,$00,$00,$00
    jsr clearScreen 
    setCursorPosition(520)
    stringCopyAt(msg,(msgEnd-msg)) 
    jsr setupNMI
    lda #255
    sta SpriteActiveReg 
    lda  #($3200/64)
    sta spritePtr1 
    .for(var x = 1; x < 8; x++) {
        setSpritePtr(x,$3200/64)
        setSprite(x,random()*270+50,random()*170+30)
        setSpriteMultiColor(x)
    }

    lda #120
    sta Sprite1XLow 
    sta Sprite1Y
    setSpriteMultiColor(0)
    setSpriteColor(0,colors.orange)
    setSpriteAuxiliaryColor(0,colors.white)
    setSpriteAuxiliaryColor(1,colors.black)
    
!loop:
    lda Timer
    cmp #30
    bne !loop- 
    lda #0 
    sta Timer 
    inc Sprite1XLow
    bne !loop- 
    lda VIC.SpriteXHighbit 
    eor #$1
    sta VIC.SpriteXHighbit  
    jmp !loop-

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
SetupIRQ:
    cli
    sei 
    rts 

nmi:
    PushRegister()
    lda $dd0d // confirm IRQ
    and #1 
    beq !exit+ 
    inc bg_clr
    lda Timer 
    clc 
    adc #1 
    sta Timer 
    lda #0 
    adc #0 
    sta Timer+1 
!exit:
    PullRegisters()
    rti

Timer:
    .word 00
PlayerXAccu:
    .byte 0
PlayerYAccu:
    .byte 0
PlayerPosX:
    .word 00
PlayerPosY:
    .byte 00
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


*=$3200
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