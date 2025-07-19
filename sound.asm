.label SIDBase = $D400

.namespace noteValues 
{
    .label C_1 = 536
    .label CSharp_1 = 568 
    .label D_1 = 602 
    .label DSharp_1 = 637
    .label E_1 = 675
    .label F_1 = 716 
    .label FSharp_1 = 758
    .label G_1 = 803 
    .label GSharp_1 = 851 
    .label A_1 = 902 
    .label ASharp_1 = 955 
    .label B_1 = 1012 
    .label C_2 = 1072
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
    .label FilterType = SIDBase+24
}

.namespace FilterTypes {
    .label Highpass = 64
    .label Bandpass = 32 
    .label Lowpass = 16
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

.macro setFiltertype(type)
{
    lda SID.FilterType
    ora #type
    sta SID.FilterType
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
    lda #%11110000
    sta SID.res_filterCtr 
    lda #%00011111
    sta SID.Volume
    lda #$13 
    sta SID.ADVoice1
    lda #$fa
    sta SID.SRVoice1
    setNote(noteValues.C_4)
    setWaveform(Waveforms.Square)
    lda #<music 
    sta $fb
    lda #>music 
    sta $fc
    ldy #0
filterSweep:
    lda #Waveforms.Square+1
    sta SID.Voice1Waveform
    lda ($fb),y
    sta SID.Voice1FreqLow
    iny
    lda ($fb),y
    sta SID.Voice1FreqHigh
    iny
    ldx #0
!stall:
    .for(var k =0;k < 300; k++) {
        nop
        nop
        nop
        nop
    }
    dex 
    beq checkY
    jmp !stall-
checkY:
    cpy #8
    bne !end+
    ldy #0
!end:
    lda #Waveforms.Square
    sta SID.Voice1Waveform
    jmp filterSweep
}
music:
    .word noteValues.C_1*4, noteValues.E_1*4,noteValues.F_1*4,noteValues.FSharp_1*4       