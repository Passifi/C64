.import source "constants.asm"
.import source "macros.asm"
.import source "graphics.asm"
.import source "sound.asm"
.import source "system.asm"
.namespace SoundEvent {
    .label Off = 0 
    .label On = 64
    .label WaveformChange = 2 
    .label FilterChange = 4
    .label ADSRChange = 8
    .label PulswidthChange = 16
    .label FrequencyChange = 128

}

.namespace EventOffset {
    .label TurnOn = On-switchStart
    .label TurnOff = Off-switchStart
    .label FrqChange = ChangeFrequency-switchStart
}

.namespace WaveformData { // lowByte for the register value,  HighByte for the VoiceNumber
    
}

*=$801
    .byte $0c,$08,$e2,$07,$9e,$20,$32,$30,$36,$32,$00,$00,$00
    
    // short bittest 
    lda #64 
    sta zeropage
    bit zeropage
    lda #32
    sta zeropage
    lda #64 
    bit zeropage
    createNMI(rasterIRQ)
    resetSID() 
    setFilter(1200)
    setDutyCycle(3400)
     
    lda #%11110000
    sta SID.res_filterCtr 
    lda #%00011111
    sta SID.Volume
    setADSR($00f0,1)
    setADSR($00f0,2)
    setADSR($00f0,3)
     
    jmp * 

rasterIRQ:
    NMIStart()
    and #(IRQCtrl.TimerAIRQ)
    beq !exit+
    inc VIC.frameColor 
    jsr soundRoutine
!exit:
    NMIEnd()    

switchOn:   // voice on a (load 0 for 1 7 for 2 14 for 3)
.break
    clc 
    ldx #0
    adc #<SID.Voice1Waveform
    sta zeropage2  
    lda #>SID.Voice1Waveform
    sta zeropage2+1 
    lda #33
    //lda (zeropage2,x)
    //ora #65
    sta (zeropage2,x)
    iny
    iny
    iny 
    rts  
switchOff:   // voice on a (load 0 for 1 7 for 2 14 for 3)
    clc 
    ldx #0
    adc #<SID.Voice1Waveform
    sta zeropage2  
    lda #>SID.Voice1Waveform
    sta zeropage2+1 
    lda (zeropage2,x)
    and #%1111110
    sta (zeropage2,x)
    iny
    iny 
    iny 
    rts  
setFrequency: // voice on a
    clc 
    ldx #0 
    adc #<SID.Voice1FreqLow
    sta zeropage2 
    lda #>SID.Voice1FreqLow
    sta zeropage2+1 
    iny
    lda (zeropage),y
    sta (zeropage2,x)
    inc zeropage2
    iny 
    lda (zeropage),y 
    sta (zeropage2,x)
    iny
    rts
soundRoutine:
    lda Timer 
    sta scr_ram+12
    dec Timer 
    bpl !test+ 
    dec Timer+1
!test:
    quickZeroWordTest(Timer)
    bne !end+
eventTest:
    lda #<MusicData 
    sta $fb 
    lda #>MusicData
    sta $fc 
    ldy Index
    lda (zeropage),y
    clc 
    adc #<switchStart
    sta switchStart+1
    lda #>switchStart 
    sta switchStart+2
    iny
    lda (zeropage),y
switchStart:
    jmp $ffff 
On:
    jsr switchOn
    jmp EndOfTable
Off:
    jsr switchOff 
    jmp EndOfTable
ChangeFrequency:
    jsr setFrequency
EndOfTable:
.break
    lda (zeropage),y
    sta Timer
    iny
    lda (zeropage),y
    sta Timer+1
    iny 
    cpy #(MusicDataEnd-MusicData)
    bcc !next+
    ldy #0
!next: 
    sty Index
!end:
    rts 
.macro quickZeroWordTest(address) {
    lda address 
    ora address+1 
}

.macro turnVoiceOff (voiceNo) {
    .var registerAddress = SID.Voice1Waveform+(voiceNo-1)*SID.VoiceLength
    lda registerAddress
    and #%11111110
    sta registerAddress
    
}

.macro setFrequency(voiceNo) {
   
    .var registerAddress = SID.Voice1FreqLow+(voiceNo-1)*SID.VoiceLength
    lda ($fb),y
    sta registerAddress
    iny 
    lda ($fb),y 
    sta registerAddress+1 
    iny  
}

.macro turnVoiceOn(voiceNo) {
    .var registerAddress = SID.Voice1Waveform+(voiceNo-1)*SID.VoiceLength
    lda registerAddress
    ora #%00000001
    sta registerAddress
 
}



Buffer: 
    .word $0000
Timer: 
    .word $0001

Index: 
    .byte 0

MusicData:
    .byte EventOffset.TurnOn,14 
    .word 0,1
    .byte EventOffset.FrqChange,14 
    .word noteValues.GSharp_1*8,1
    .byte EventOffset.TurnOn, $07
    .word noteValues.ASharp_1*4,12
     .byte EventOffset.FrqChange, $07
    .word noteValues.C_1*4, 20
    .byte EventOffset.TurnOn, $00
    .word noteValues.ASharp_1*2,12
    .byte EventOffset.FrqChange, $00
    .word noteValues.E_1*4, 20
  .byte EventOffset.TurnOn, $07
    .word noteValues.A_1*4,12
     .byte EventOffset.FrqChange, $07
    .word noteValues.B_1*4, 20
    .byte EventOffset.TurnOn, $00
    .word noteValues.ASharp_1*2,12
    .byte EventOffset.FrqChange, $00
    .word noteValues.F_1*4, 20
    .byte EventOffset.FrqChange,14 
    .word noteValues.A_1*8,120
 


    
    
    // structure event, eventvalue, timerValue
    
MusicDataEnd: