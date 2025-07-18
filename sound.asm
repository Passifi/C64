.label SIDBase = $D400

.namespace noteValues 
{
    .label C_1 = $022a
    .label C_4 = $1150
}

.namespace Waveforms {
    .label Square = 64 
    .label Noise = 128 
    .label Saw = 32
    .label Triangle = 16
}

.namespace SID {
    
    .label Voice1FreqLow =SIDBase 
    .label Voice1FreqHigh =SIDBase +1
    .label Voice1PulsewaveDutyCycleLow =SIDBase +2  
    .label Voice1PulsewaveDutyCycleHigh =SIDBase+3 
    .label Voice1Waveform = SIDBase+ 4
    .label ADVoice1 = SIDBase + 5
    .label SRVoice1 = SIDBase +6
    .label filterLow = SIDBase + $15 
    .label filterHigh = SIDBase + $16
    .label res_filterCtr = SIDBase + $17 
    .label Volume = SIDBase+24
}

.macro setNote(note) {
    lda #<note
    sta SID.Voice1FreqLow
    lda #>note
    sta SID.Voice1FreqHigh
}

.macro setFilter(value) {
    lda #<value 
    sta SID.filterLow
    lda #>value 
    sta SID.filterHigh
}


.macro setWaveform(value) {
   lda #value+1 
   sta SID.Voice1Waveform 
}

.macro setDutyCycle(value) {
    lda #<value 
    sta SID.Voice1PulsewaveDutyCycleLow
    lda #>value 
    sta SID.Voice1PulsewaveDutyCycleHigh
}

.macro resetSID() {
    lda #0 
    .for(var x = 0; x< 25; x++) {
        sta SIDBase+x
    }
}

.macro basicTestASM() {
    resetSID() 
    setFilter(1200)
    setDutyCycle(200)
    lda #%11110001
    sta SID.res_filterCtr 
    lda #%00011111
    sta SID.Volume
    lda #$1f 
    sta SID.ADVoice1
    lda #$f1
    sta SID.SRVoice1
    setNote(noteValues.C_4)
    setWaveform(Waveforms.Square)
filterSweep:
    jmp filterSweep

}

music:
    .byte     