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
    lda #%11110001
    sta SID.res_filterCtr 
    lda #%00011111
    sta SID.Volume
    lda #$13 
    sta SID.ADVoice1
    lda #$fa
    sta SID.SRVoice1
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
    clc 
    ldx #0
    adc #<SID.Voice1Waveform
    sta zeropage2  
    lda #>SID.Voice1Waveform
    sta zeropage2+1 
    lda (zeropage2,x)
    ora #1
    sta (zeropage2,x)
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
    rts  
setFrequency: // voice on a
    clc 
    ldx #0 
    adc #<SID.Voice1FreqLow
    sta zeropage2 
    lda #>SID.Voice1FreqLow
    sta zeropage2+1 
    lda (zeropage),y
    sta (zeropage2,x)
    inc zeropage2
    iny 
    lda (zeropage),y 
    sta (zeropage2,x)
    rts
soundRoutine:
    
    dec Timer 
    quickZeroWordTest(Timer)
    bne !end+
eventTest:
    // if timer is 0 we test
    // All 0 execute switch voice off (two ways either direct jump to different
    // voice sections or just setting the register with the zeropage and adding)
    // 1 Switch voice on dito 
    // 2 etc so I need a subroutine for each of these 
    // last if new timer is 0 we inc the index and jump back here 
    
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
switchStart:
    jmp $ffff 
On:
Off:
ChangeFrequency:
EndOfTable:
    setFrequency(1)
    cpy #11 
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
    .word $0101

Index: 
    .byte 0

MusicData:
    .byte SoundEvent.On
    .word noteValues.ASharp_1, 1200
    .word SoundEvent.WaveformChange,(Waveforms.Saw<<8 | 01) , 1200
    .word SoundEvent.On, noteValues.ASharp_1, 1200
    .word SoundEvent.On, noteValues.ASharp_1, 1200
    // structure event, eventvalue, timerValue
    .word noteValues.ASharp_1,340
    .word noteValues.FSharp_1,340
    .word noteValues.GSharp_1,340
    .word 00,340
    .word noteValues.B_1,1200
    .word noteValues.C_1,32
    .word noteValues.ASharp_1,120
    .word noteValues.ASharp_1,323
    .word noteValues.ASharp_1,323
    .word noteValues.ASharp_1
    .word noteValues.ASharp_1
    .word noteValues.ASharp_1
    .word noteValues.ASharp_1
    .word noteValues.ASharp_1
    .word noteValues.ASharp_1