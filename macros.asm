
.macro PushRegister() {
    pha 
    txa 
    pha
    tya 
    pha 
}

.macro PullRegisters() {
    pla 
    tay 
    pla 
    tax
    pla
}

.namespace petscii {
    .label blank = 32
}

.macro loadAddress(address,page) {
    lda #<address
    sta page 
    lda #>address 
    sta page+1
}
