
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
