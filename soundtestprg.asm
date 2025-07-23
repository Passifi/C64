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
    .label setWaveform = setWaveformCase-switchStart 
    .label FreqChange = ChangeFrequency-switchStart
}

.namespace WaveformData { // lowByte for the register value,  HighByte for the VoiceNumber
    
}
*=$801
    .byte $0c,$08,$e2,$07,$9e,$20,$32,$30,$36,$32,$00,$00,$00
    createNMI(rasterIRQ)
    resetSID() 
    setFilter(1200)
    setDutyCycle($ff,1)
    setDutyCycle($ff,2)
    setDutyCycle($ff,3)
    lda #%11110000
    sta SID.res_filterCtr 
    lda #%00011111
    sta SID.Volume
    setADSR($03aa,1)
    setADSR($03aa,2)
    setADSR($03a9,3)
    jmp * 

rasterIRQ:
    NMIStart()
    and #(IRQCtrl.TimerAIRQ)
    beq !exit+
    inc VIC.frameColor 
    jsr soundRoutine
!exit:
    NMIEnd()   

switchOn:   // voice on a (load 0 for 1 7 for 2 14 for 3) clc 
    tax
    clc
    adc #<SID.Voice1Waveform
    sta SIDZeropageLow  
    lda #>SID.Voice1Waveform
    sta SIDZeropageLow+1 
    txa
    clc 
    adc #<Voice1Waveform
    sta $fd 
    lda #>Voice1Waveform
    adc #0
    sta $fe
    ldx #0
    lda ($fd,x)
    ora #1
    sta (SIDZeropageLow,x)
    iny 
    rts  
switchOff:   // voice on a (load 0 for 1 7 for 2 14 for 3)
    tax
    clc
    adc #<SID.Voice1Waveform
    sta SIDZeropageLow  
    lda #>SID.Voice1Waveform
    sta SIDZeropageLow+1 
    txa
    clc 
    adc #<Voice1Waveform
    sta $fd 
    lda #>Voice1Waveform
    adc #0
    sta $fe
    ldx #0
    lda ($fd,x)
    and #%11111110
    sta (SIDZeropageLow,x)
    iny 
    rts    
setWaveform:
    clc 
    ldx #0
    adc #<Voice1Waveform 
    sta SIDZeropageLow 
    lda #>Voice1Waveform 
    adc #0 
    sta SIDZeropageHigh 
    iny 
    lda (MusicdataZeropageLow),y 
    sta (SIDZeropageLow,x)
    iny 
    rts 
setFrequency: // voice on a
    clc 
    ldx #0 
    adc #<SID.Voice1FreqLow
    sta SIDZeropageLow 
    lda #>SID.Voice1FreqLow
    sta SIDZeropageLow+1 
    iny
    lda (MusicdataZeropageLow),y
    sta (SIDZeropageLow,x)
    inc SIDZeropageLow
    iny 
    lda (MusicdataZeropageLow),y 
    sta (SIDZeropageLow,x)
    iny
    rts
soundRoutine:
    lda Timer 
    sec 
    sbc #1
    sta Timer
    bcs !test+ 
    dec Timer+1
!test:
    quickZeroWordTest(Timer)
    bne !end+
eventTest:
!Instructions:
    lda Index 
    sta MusicdataZeropageLow 
    lda Index+1 
    sta MusicdataZeropageHigh
    ldy #0
    lda (MusicdataZeropageLow),y
    clc 
    adc #<switchStart
    sta switchStart+1
    lda #>switchStart 
    adc #0 
    sta switchStart+2
    iny
    lda (MusicdataZeropageLow),y
switchStart:
    jmp $ffff 
On:
    jsr switchOn
    jmp EndOfTable
Off:
    jsr switchOff 
    jmp EndOfTable
setWaveformCase:    
    jsr setWaveform 
    jmp EndOfTable
ChangeFrequency:
    jsr setFrequency
EndOfTable:
    lda (MusicdataZeropageLow),y
    sta Timer
    iny
    lda (MusicdataZeropageLow),y
    sta Timer+1
    iny 
    tya 
    clc
    adc Index 
    sta Index 
    bcc !ZeroTest+
    inc Index+1
!ZeroTest:
    quickZeroWordTest(Timer)
    beq !Instructions- 
    lda Index 
    cmp #<MusicDataEnd 
    bne !next+
    lda Index+1 
    cmp #(>MusicDataEnd)
    bne !next+
    lda #>MusicData
    sta Index+1 
    lda #<MusicData
!next:
    sta Index
!end:
    rts 

.macro quickZeroWordTest(address) {
    lda address 
    ora address+1 
}
 
Buffer: 
    .word $0000
Timer: 
    .word $0001
Index: 
    .word MusicData
Voice1Waveform:
    .byte 0
    .byte 0,0,0,0,0,0 
Voice2Waveform:
    .byte 0
    .byte 0,0,0,0,0,0 
Voice3Waveform:
    .byte 0 



MusicData:
    
    .byte EventOffset.setWaveform,Voice1Offset
    .byte Waveforms.Triangle 
    .word 0 
    .byte EventOffset.setWaveform,Voice2Offset
    .byte Waveforms.Triangle 
    .word 0 
    .byte EventOffset.setWaveform,Voice3Offset
    .byte Waveforms.Square
    .word 0 
    .byte EventOffset.TurnOn,Voice1Offset
    .word 0 
    .byte EventOffset.TurnOn,Voice2Offset
    .word 0 
    .byte EventOffset.TurnOn,Voice3Offset
    .word 0    
    .byte EventOffset.FreqChange,Voice1Offset
    .word noteValues.CSharp_1*8 
    .word 0 
    .byte EventOffset.FreqChange,Voice2Offset
    .word noteValues.E_1*8 
    .word 0 
    .byte EventOffset.FreqChange,Voice3Offset
    .word noteValues.GSharp_1*8 
    .word 200
    .byte EventOffset.FreqChange,Voice1Offset
    .word noteValues.E_1*8 
    .word 0 
    .byte EventOffset.FreqChange,Voice2Offset
    .word noteValues.ASharp_1*8 
    .word 0 
    .byte EventOffset.FreqChange,Voice3Offset
    .word noteValues.D_1*8 
    .word 200
    .byte EventOffset.FreqChange,Voice1Offset 
    .word noteValues.FSharp_1*8,210
    .byte EventOffset.FreqChange,Voice1Offset
    .word noteValues.B_1*8 
    .word 0 
    .byte EventOffset.FreqChange,Voice2Offset
    .word noteValues.E_1*8 
    .word 0 
    .byte EventOffset.FreqChange,Voice3Offset
    .word noteValues.A_1*8 
    .word 1300
     .byte EventOffset.TurnOff,Voice1Offset
    .word 0 
    .byte EventOffset.TurnOff,Voice2Offset
    .word 0 
    .byte EventOffset.TurnOff,Voice3Offset
    .word 320   
MusicDataEnd: