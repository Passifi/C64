.namespace CIA1 {
    .label Base = $DC00
    .label DataPortA = Base
    .label DataPortB = Base + 1
    .label TimerALowByte = Base + 4
    .label TimerAHighByte = Base + 5
    .label TimerBLowByte = Base +6 
    .label TimerBHighByte = Base + 7
    .label IRQStatus = Base + 13 
    .label IRQCtrl = Base + 13 
    .label TimerACtrl = Base + 14
    .label TimerBCtrl = Base + 15
}

.namespace CIA2 {
    .label Base = $DD00 
     .label DataPortA = Base
    .label DataPortB = Base + 1
    .label TimerALowByte = Base + 4
    .label TimerAHighByte = Base + 5
    .label TimerBLowByte = Base +6 
    .label TimerBHighByte = Base + 7
    .label IRQStatus = Base + 13 
    .label IRQCtrl = Base + 13 
    .label TimerACtrl = Base + 14
    .label TimerBCtrl = Base + 15   
}

.namespace IRQCtrl {
    .label TimerAIRQ  = 1 
    .label TimerBIRQ = 2 
    .label AlarmIRQ = 4 
    .label SDRFullIRQ = 8
    .label set = 128
}


.macro ACKCIA1IRQ () {
    lda CIA1.IRQStatus
}

.macro ACKCIA2IRQ() {
    lda CIA2.IRQStatus
}

.macro NMIStart() {
    pha
    txa
    pha 
    tya 
    pha 
    ACKCIA2IRQ()
    
}

.macro NMITest(flag) { // presumes that we just called NMIStart
    and #flag 
    //beq !exit+ 
    //code

}

.macro NMIEnd() {
   pla 
   tay 
   pla 
   tax 
   pla 
   rti 
}

.macro createNMI(nmiAddress) {
    ldx CIA2.IRQCtrl // CIA-2
    deactiveAllIRQCIA2() 
    lda #<nmiAddress
    sta $0318 
    lda #>nmiAddress 
    sta $0319
    setTimerA(2,65000)
    lda #1
    sta CIA2.TimerACtrl
    txa 
    setIRQCIA2(IRQCtrl.TimerAIRQ)
}

.macro setIRQCIA2(flags) {
    ora #%10000001
    sta CIA2.IRQCtrl 
}

.macro deactiveAllIRQCIA1() {
    lda #%01111111
    sta CIA1.IRQCtrl
}
.macro deactiveAllIRQCIA2() {
    lda #%01111111
    sta CIA2.IRQCtrl
}


.macro setTimerA(ciaNo,value) {
    .if(ciaNo == 1) {
        lda #<value 
        sta CIA1.TimerALowByte 
        lda #>value 
        sta CIA1.TimerAHighByte
    }
    else {
.break
        lda #<value 
        sta CIA2.TimerALowByte 
        lda #>value 
        sta CIA2.TimerAHighByte
    }
}