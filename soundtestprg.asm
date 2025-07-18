.import source "constants.asm"
.import source "macros.asm"
.import source "graphics.asm"
.import source "sound.asm"
.import source "system.asm"
*=$801
    .byte $0c,$08,$e2,$07,$9e,$20,$32,$30,$36,$32,$00,$00,$00
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
    
soundRoutine:
    inc Timer 
    lda Timer 
    cmp #12
    bne !end+
    lda #0 
    sta Timer
    lda #<MusicData 
    sta $fb 
    lda #>MusicData
    sta $fc 
    ldy Index
    lda #Waveforms.Saw|1
    sta SID.Voice1Waveform
    lda ($fb),y
    sta SID.Voice1FreqLow 
    iny 
    lda ($fb),y 
    sta SID.Voice1FreqHigh 
    iny
    cpy #11 
    bcc !next+
    ldy #0
!next: 
    sty Index
!end:
    rts 
Timer: 
    .word $0101

Index: 
    .byte 0
MusicData:
    .word noteValues.ASharp_1
    .word noteValues.FSharp_1
    .word noteValues.GSharp_1
    .word noteValues.B_1
    .word noteValues.C_1
    .word noteValues.ASharp_1
    .word noteValues.ASharp_1
    .word noteValues.ASharp_1
    .word noteValues.ASharp_1
    .word noteValues.ASharp_1
    .word noteValues.ASharp_1
    .word noteValues.ASharp_1
    .word noteValues.ASharp_1
    .word noteValues.ASharp_1