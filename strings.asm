.macro stringCopy(str,length) {

    lda #<scr_ram
    sta zeropage
    lda #>scr_ram
    sta zeropage+1 
    lda #<str
    sta zeropage+2
    lda #>str 
    sta zeropage+3   
    ldy #(length-1)
!loop:
    lda (zeropage+2),y 
    sta (zeropage),y 
    dey 
    bpl !loop-



}


.macro stringCopyAt(str,length) {

    lda #<scr_ram
    clc
    adc cursorPosition 
    sta zeropage
    lda #>scr_ram
    adc cursorPosition+1 
    sta zeropage+1 
    lda #<str
    sta zeropage+2
    lda #>str 
    sta zeropage+3   
    ldy #(length-1)
!loop:
    lda (zeropage+2),y 
    sta (zeropage),y 
    dey 
    bpl !loop-

}

.macro setCursorPosition(newPos) {

    lda #<newPos 
    sta cursorPosition
    lda #>newPos 
    sta cursorPosition+1

}

cursorPosition: 
    .word 00 