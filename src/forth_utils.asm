; UTILITIES --------------------------
STACK_UNDERFLOW:
    ldx #<STACK_UFLOW_S
    ldy #>STACK_UFLOW_S
    jsr PRINTS
    jmp MAIN

HEX_2_DECS: .(
    stx XSTORE
    ldy #$0
    lda #$0
    pha
L:
    lda NUM_CONV_HEX
    beq Z
    ldx #$A
    jsr DIV
    sta NUM_CONV_HEX
    txa
    jsr NTOC
    pha
    iny
    cpy #$3
    beq P
    jmp L
Z:
    cpy #$0
    bne P
    lda #$30
    pha
P:
    pla
    beq E
    sta CHAROUT
    jmp P
E:
    ldx XSTORE
    rts
.)

STACK_POP: .(                  
    phy
    ldy STACK_OFFSET   
    cpy #$0           
    beq SPER            
    dey                 
    lda STACK, Y        
    sty STACK_OFFSET   
    ply
    jmp SPN            
SPER:
    jmp STACK_UNDERFLOW 
SPN:rts
.)                  

STACK_PUSH: .(
    phy
    ldy STACK_OFFSET    
    sta STACK, Y        
    iny                
    beq SOF
    sty STACK_OFFSET   
    ply
    rts
SOF:ldx #<STACK_OFLOW_S
    ldy #>STACK_OFLOW_S
    jmp MAIN
.)


; Copy the current token at 
COPY_TOKEN: .(
    phx
    ldx #$0
    ldy CURLINE_IDX
L:  lda (CURLINE_L), y
    beq E
    cmp #SPACE
    beq E
    sta TOKEN_BUFF, x
    inx
    iny
    cmp #';'
    beq E
    jmp L
E:  stx WORD_LEN
    sty CURLINE_IDX
    stz TOKEN_BUFF, x
    plx
    rts
.)
#print COPY_TOKEN

RUN_SUBSTRING: .(
    clc
    inc IN_FUNCTION
    lda CURLINE_L
    pha
    lda CURLINE_H
    pha
    lda CURLINE_IDX
    pha
    stz CURLINE_IDX
    ldy #$0
    lda (LL_CURL), y
    clc
    adc #$2
    adc LL_CURL
    sta LL_CURL
    bcc NO_CARRY
    inc LL_CURH
NO_CARRY:
    ldx LL_CURL
    ldy LL_CURH
    jmp PARSE_LINE
.)


LOOP_END_MISSING: .(
    jsr NEWLINE
    ldx #<LOOP_ENDS
    ldy #>LOOP_ENDS
    jsr PRINTS
    jmp MAIN
.)

