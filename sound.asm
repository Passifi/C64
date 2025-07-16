.label SIDBase = $D400

.namespace noteValues 
{
    .label C_1 = $0218
}

.namespace SID {
    
    .label Voice1FreqLow =SIDBase 
    .label Voice1FreqHigh =SIDBase +1
    .label Voice1Waveform = SIDBase+ 4
    .label ADVoice1 = SIDBase + 5
    .label SRVoice1 = SIDBase +6
    .label Volume = SIDBase+24
}

.macro setNote(note) {
    lda #<note
    sta SID.Voice1FreqHigh
    lda #>note
    sta SID.Voice1FreqLow
}

.macro basicTestASM() {
    lda #0 
    .for(var x = 0; x< 24; x++) {
        sta SIDBase 
    }
    lda #15
    sta SID.Volume
    lda #$09 
    sta SID.ADVoice1
    lda #$00
    sta SID.SRVoice1
    setNote(noteValues.C_1) 
    lda #17 // lowest bit is gate
    sta SID.Voice1Waveform

}