
; Gets the next token in CURLINE_* buffer.
; Sets CURLINE_IDX and Y to the next available character
; Ignores spaces 
; RETURNS 1 on next token found
;         0 on end of line (null terminated)
GETTOKEN:
    ldy CURLINE_IDX
GETTOKEN_L:
    lda (CURLINE_L), y
    beq GETTOKEN_EOL    ; if null found, return end of line
    cmp #SPACE
    bne GETTOKEN_RET    ; return if we're already on next char
    iny
    jmp GETTOKEN_L      ; if it is a space, continue to next char
GETTOKEN_EOL:
    clc
    lda #$0
    rts
GETTOKEN_RET:
    sty LINE_IN_IDX
    sty CURLINE_IDX
    lda #$1
    rts
