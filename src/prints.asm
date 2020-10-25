; PRINT String (null terminated)
; Pass string vector as X (low) and Y (high)
; Example:
;       ldx #<STRING
;       ldy #>STRING
;       jsr PRINTS
PRINTS:
    stx PRL
    sty PRH
    ldy #$0
PRINTS_LOOP:
    lda (PRL), y
    beq PRINTS_END
    sta CHAROUT
    iny
    cpy #$FF
    beq PRINTS_END
    jmp PRINTS_LOOP
PRINTS_END:
    rts
#print PRINTS


NEWLINE:
    lda #CR
    sta CHAROUT
    lda #LF
    sta CHAROUT
    rts
