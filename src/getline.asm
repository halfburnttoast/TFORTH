GETLINE:
    jsr NEWLINE
    ldx #$0             ; reset character offset
    lda #PROMPT
    sta CHAROUT
GETLINE_GETC:
    lda CHARIN          ; get character from IO
    beq GETLINE_GETC    ;   if no character, loop
    cmp #ESC            ; is ESCAPE key?
    beq GETLINE         ;   scrap entire line
    cmp #CR             ; is ENTER key?
    beq GETLINE_E       ;   return
    cmp #BS             ; is backspace?
    beq GETLINE_BS
    cmp #$5F            ; backspace may be mapped to this for some reason
    beq GETLINE_BS
    sta LINE_IN, x      ; store character in buffer
    sta CHAROUT         ; echo character back to IO
    inx
    cpx #$0             ; character overflow?
    beq GETLINE         ;   scrap entire line
    jmp GETLINE_GETC    ; get next character 
GETLINE_BS:
    cpx #$0
    beq GETLINE
    dex
    sta CHAROUT
    jmp GETLINE_GETC
GETLINE_E:
    lda #$0
    sta LINE_IN, x      ; null terminate line
    rts
