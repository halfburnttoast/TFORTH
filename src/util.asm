// requires two, consecutive zero-page variables 
//  B16L,B16H


; Shift a nibble onto B16L, B16H
BADD:
    ldy #$4
BADD_L:
    asl B16L
    rol B16H
    dey
    bne BADD_L
    ora B16L
    sta B16L
    rts

; Clears B16L, B16H
BCLR:
    lda #$0
    sta B16L
    sta B16H
    rts


; Convert ASCII hex character in register A to nibble
; Returns A
CTON:
    sec
    sbc #$30
    cmp #$0A
    bcc CTON_E
    sec
    sbc #$07
    clc
CTON_E:
    rts

; convert binary number in A to two hex ascii characters
BTOA:
    pha
    and #$0F
    jsr NTOC
    tay
    pla
    and #$F0
    ror
    ror
    ror
    ror
    jsr NTOC
    rts
    
; convert nibble in A to ascii character, returns A
NTOC:
    cmp #$0A
    bcc NTOC_S
    clc
    adc #$07
NTOC_S:
    adc #$30
    rts
    
    
; Multiply A by X times
; Returns A
MULT:
    cmp #$0
    beq MULT_RETURN
    sta MULT_TEMP
    lda #$0
    cpx #$0
    beq MULT_RETURN
    clc    
MULT_LOOP:
    dex
    bmi MULT_RETURN
    adc MULT_TEMP
    jmp MULT_LOOP
MULT_RETURN:
    rts


; Divide A by X
; Returns A (quot) and X (rem)
DIV:
    sty YSTORE
    ldy #$0
    stx DIV_TEMP
    sec
DIV_LOOP:
    cmp DIV_TEMP
    bcc DIV_END
    sbc DIV_TEMP
    iny
    jmp DIV_LOOP
DIV_END:
    tax
    tya
    ldy YSTORE
    rts

