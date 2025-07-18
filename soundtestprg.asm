.import source "constants.asm"
.import source "macros.asm"
.import source "graphics.asm"
.import source "sound.asm"

*=$801

    .byte $0c,$08,$e2,$07,$9e,$20,$32,$30,$36,$32,$00,$00,$00
    setupRasterIRQ(rasterIRQ)
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
    jmp * 
// setup start 
// seutp the irq 

rasterIRQ:
    ACKRaster()
    lda VIC.RasterlineInterrupt 
    cmp #250
    bne !end+
    dec Timer 
    lda Timer 
    cmp #0 
    bne !end+ 
    dec Timer+1
    lda Timer+1 
    cmp #0 
    bne !end+ 
    jsr soundRoutine
!end:  
    
    jmp $ea31

soundRoutine:
    lda #<MusicData 
    sta $fb 
    lda #>MusicData
    sta $fc 
    ldy Index
    lda #Waveforms.Square+1
    sta SID.Voice1Waveform
    lda ($fb),y
    sta SID.Voice1FreqHigh 
    iny 
    lda ($fb),y 
    sta SID.Voice1FreqLow 
    iny 
    lda ($fb),y
    sta Timer+1 
    iny 
    lda ($fb),y 
    sta Timer 
    tya 
.break
    sta Index
    rts 
Timer: 
    .word $0101

Index: 
    .byte 0
MusicData:
    .word noteValues.ASharp_1, 340
    .word noteValues.FSharp_1, 340
    .word noteValues.GSharp_1, 340
    .word noteValues.B_1, 340
    .word noteValues.C_1, 340
    .word $0, 340
    .word noteValues.ASharp_1, 340
    .word $0, 340