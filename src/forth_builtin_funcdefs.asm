; BUILT-IN FUNCTIONS
; Called via function pointer in linked-list
#ifdef PARN_IGNORE
F_IGNORE:
    jmp FUNC_END
#endif

F_SEE: .(
    jsr GETTOKEN
    jsr COPY_TOKEN
    lda #<USER_FUNC
    sta LL_CURL
    lda #>USER_FUNC
    sta LL_CURH
    jsr USER_SEEK
    beq E
    ldy #$0
    lda (LL_CURL), y
    adc #$2
    adc LL_CURL
    sta LL_CURL
    bcc NO_CARRY
    inc LL_CURH
NO_CARRY:
    ldx LL_CURL
    ldy LL_CURH
    jsr PRINTS
    jsr NEWLINE
E:  jmp FUNC_END
.)


F_ROT: .(
    jsr STACK_POP   ; moves to POS 2
    tax
    jsr STACK_POP   ; moves to POS 3
    tay
    jsr STACK_POP   ; moves to POS 1
    sta TEMP
    tya
    jsr STACK_PUSH
    txa
    jsr STACK_PUSH
    lda TEMP
    jsr STACK_PUSH
    jmp FUNC_END
.)

F_OVER: .(
    jsr STACK_POP
    tay
    jsr STACK_POP
    tax
    jsr STACK_PUSH
    tya
    jsr STACK_PUSH
    txa
    jsr STACK_PUSH
    jmp FUNC_END
.)

; Nonblocking keyboard input. Pushes 0 if no key pressed.
F_NOBLOCK_KEY: .(
    lda CHARIN
    jsr STACK_PUSH
    jmp FUNC_END
.)

F_VAR_READ: .(
    jsr STACK_POP
    tax
    lda VARIABLE_PAGE, x
    jsr STACK_PUSH
    jmp FUNC_END    
.)

F_VAR_WRITE: .(
    jsr STACK_POP
    tax
    jsr STACK_POP
    sta VARIABLE_PAGE, x
    jmp FUNC_END
.)


; Begin while loop. Works more like a do-while loop. The conditional
; is checked at the end of the first loop rather than the beginning.
F_BEGIN: .(
    lda IN_WHILE_LOOP
    beq NO_NEST
    pha
NO_NEST:
    inc IN_WHILE_LOOP
    jsr GETTOKEN
    sty WHILE_LOOP_IDX
    jmp FUNC_END
.)

F_WHILE: .(
    lda IN_WHILE_LOOP
    beq ERR
    jsr STACK_POP
    cmp #$0
    beq END_WHILE_LOOP
    lda WHILE_LOOP_IDX
    sta CURLINE_IDX
    jmp FUNC_END
END_WHILE_LOOP:
    dec IN_WHILE_LOOP
    jmp FUNC_END
ERR:ldx #<WHILE_ERRS
    ldy #>WHILE_ERRS
    jsr PRINTS
    jmp MAIN
.)

F_EMIT: .(
    jsr STACK_POP
    sta CHAROUT
    jmp FUNC_END
.)

F_KEY: .(
L:  lda CHARIN
    beq L
    jsr STACK_PUSH
    jmp FUNC_END
.)

F_INVERT: .(
    jsr STACK_POP
    cmp #$0
    beq ONE
    lda #$0
E:  jsr STACK_PUSH
    jmp FUNC_END
ONE:
    lda #$FF
    bra E
.)

F_OR: .(
    jsr STACK_POP
    sta TEMP
    jsr STACK_POP
    ora TEMP
    jsr STACK_PUSH
    jmp FUNC_END
.)

F_AND: .(
    jsr STACK_POP
    sta TEMP
    jsr STACK_POP
    and TEMP
    jsr STACK_PUSH
    jmp FUNC_END    
.)

F_LT: .( 
    jsr STACK_POP
    sta TEMP
    jsr STACK_POP
    cmp TEMP
    bcs FALSE
    beq FALSE
    lda #$FF
E:  jsr STACK_PUSH
    jmp FUNC_END
FALSE:
    lda #$0
    bra E
.)

F_GT: .(
    jsr STACK_POP
    sta TEMP
    jsr STACK_POP
    cmp TEMP
    bcc FALSE
    beq FALSE
    lda #$FF
E:  jsr STACK_PUSH
    jmp FUNC_END
FALSE:
    lda #$0
    bra E
.)

F_EQ: .(
    jsr STACK_POP
    sta TEMP
    jsr STACK_POP
    cmp TEMP
    bne NOT_EQUAL
    lda #$FF
E:  jsr STACK_PUSH
    jmp FUNC_END
NOT_EQUAL:
    lda #$0
    bra E
.)

F_IF: .(
    jsr STACK_POP           ; gather boolean, if stack is empty this will auto-terminate
    inc IN_IF_BLOCK         ; update system state that we are now in a if block
    cmp #$0
    beq FALSE
    jmp FUNC_END            ; bool is true, execute statement after IF 
                            ;   ended when either ELSE or THEN are encountered
FALSE:                      ; bool is false, execute statement after ELSE or THAN
    ldy CURLINE_IDX
LS: ldx #$0
L1: lda (CURLINE_L), y
    beq NO_ELSE
    iny
    cmp ELSE_S, x
    bne LS
    inx
    cpx #$5
    bne L1
    sty CURLINE_IDX
    jmp FUNC_END
NO_ELSE:
    jsr F_SEEK_THEN
    jmp FUNC_END
.)

F_ELSE: .(                  ; if ELSE is executed by the interpreter, it must have been
    lda IN_IF_BLOCK         ;   preceeded by an IF statement that was true. Thus ELSE
    beq ERR                 ;   contents will never run. Seek to after THEN statement 
                            ;   and exit IF block
    jsr F_SEEK_THEN
    jmp F_THEN
ERR:ldx #<IF_ERRS
    ldy #>IF_ERRS
    jsr PRINTS
    jmp MAIN
.)

F_SEEK_THEN: .(             ; Run until we find THEN. Set CURLINE_IDX to char just after
    ldy CURLINE_IDX
LS: ldx #$0
L1: lda (CURLINE_L), y
    beq ERR
    iny
    cmp THEN_S, x
    bne LS
    inx
    cpx #$5
    bne L1
    sty CURLINE_IDX         ; THEN statement found, execute code after it
    rts
ERR:ldx #<THEN_ERRS
    ldy #>THEN_ERRS
    jsr PRINTS
    jmp MAIN
.)

F_THEN: .(                  ; if THEN is executed by the interpreter, than we're done
    lda IN_IF_BLOCK         ;   executing the IF block. Return to normal operation.
    beq ERR
    dec IN_IF_BLOCK
    jmp FUNC_END
ERR:ldx #<IF_ERRS
    ldy #>IF_ERRS
    jsr PRINTS
    jmp MAIN
.)

F_LOOP_I: .(
    lda IN_LOOP
    beq ERR
    lda LOOP_COUNT
    jsr STACK_PUSH
    jmp FUNC_END
ERR:ldx #<LOOP_ERRS
    ldy #>LOOP_ERRS
    jsr PRINTS
    jmp MAIN
.)

F_LOOP: .(
    lda IN_LOOP
    beq ERR
    inc LOOP_COUNT
    lda LOOP_COUNT
    cmp LOOP_LIMIT
    beq EXIT_LOOP
    lda LOOP_BEGIN_IDX
    sta CURLINE_IDX
    jmp FUNC_END
EXIT_LOOP:
    dec IN_LOOP
    beq NO_NEST
    pla
    sta LOOP_LIMIT
    pla
    sta LOOP_COUNT
    pla
    sta LOOP_BEGIN_IDX
NO_NEST:
    jmp FUNC_END
ERR:ldx #<LOOP_ERRS
    ldy #>LOOP_ERRS
    jsr PRINTS
    jmp MAIN
.)

; Begin a loop
F_DO: .(
    lda IN_LOOP
    beq NO_NEST
    lda LOOP_BEGIN_IDX
    pha
    lda LOOP_COUNT
    pha
    lda LOOP_LIMIT
    pha
NO_NEST:
    jsr GETTOKEN
    sty LOOP_BEGIN_IDX
    jsr STACK_POP
    sta LOOP_COUNT
    jsr STACK_POP
    sta LOOP_LIMIT
    inc IN_LOOP
    jmp FUNC_END
.)
    
F_DROP:
    jsr STACK_POP
    jmp FUNC_END

F_SWAP:
    jsr STACK_POP
    tax
    jsr STACK_POP
    sta TEMP
    txa
    jsr STACK_PUSH
    lda TEMP
    jsr STACK_PUSH
    jmp FUNC_END

F_MOD:
    jsr STACK_POP
    tax
    jsr STACK_POP
    jsr DIV
    txa
    jsr STACK_PUSH
    jmp FUNC_END

F_DIV: .(
    jsr STACK_POP
    cmp #$0
    jmp ERR
    tax
    jsr STACK_POP
    jsr DIV
    jsr STACK_PUSH
    jmp FUNC_END
ERR:ldx #<DIVZ_ERRS
    ldy #>DIVZ_ERRS
    jsr PRINTS
    jmp MAIN
.)

F_MULT: 
    jsr STACK_POP
    tax
    jsr STACK_POP
    jsr MULT
    jsr STACK_PUSH
    jmp FUNC_END

F_CR: .(
    jsr NEWLINE
    jmp FUNC_END
.)

F_STR: .(
    ldy CURLINE_IDX
    iny                 ; skip first space
L:  lda (CURLINE_L), y
    cmp #$22
    beq E
    sta CHAROUT
    iny
    jmp L
E:  iny
    sty CURLINE_IDX
    jmp FUNC_END
.)

F_DUP: .(
    jsr STACK_POP
    jsr STACK_PUSH
    jsr STACK_PUSH
    jmp FUNC_END
.)

F_ADD: .(
    jsr STACK_POP
    sta TEMP
    jsr STACK_POP
    clc
    adc TEMP
    jsr STACK_PUSH
    jmp FUNC_END
.)

F_SUB: .(
    jsr STACK_POP
    sta TEMP
    jsr STACK_POP
    sec
    sbc TEMP
    jsr STACK_PUSH
    jmp FUNC_END
.)

F_PRINT: .(
    jsr STACK_POP
    sta NUM_CONV_HEX
    jsr HEX_2_DECS
    lda #SPACE
    sta CHAROUT
    jmp FUNC_END 
.)

F_DUMP: .(
    ldx #$0
L:  cpx STACK_OFFSET
    beq END
    lda STACK, x
    sta NUM_CONV_HEX
    jsr HEX_2_DECS
    lda #SPACE
    sta CHAROUT
    inx
    jmp L
END:
    jmp FUNC_END
.)

F_QUIT: .(
    jmp ($FFFA)
.)

; Insert a function string into RAM with the format:
;   1 byte  -   length of function name
;   n bytes -   function name string
;   2 bytes -   pointer to next node in list
;   n bytes -   string content of function, ';' terminated
F_DEFINE: .(
    jsr GETTOKEN
    ldx #$0
L:  lda (CURLINE_L), y      ; copy function name to TOKEN_BUFF
    bne N 
    jmp ERR
N:  cmp #SPACE
    beq SAVE_SIZE
    sta TOKEN_BUFF, x
    iny
    beq ERR
    inx
    beq ERR
    jmp L
SAVE_SIZE:
    sty CURLINE_IDX         ; move index past token we just copied
    txa
    ldy #$0
    sta (NEXT_USER_L), y
SAVE_NAME:
    txa
    tay
    dex
SNL:lda TOKEN_BUFF, x
    sta (NEXT_USER_L), y
    dex
    dey
    beq COPY_FUNC
    jmp SNL
COPY_FUNC:                  ; copy function definition to TOKEN_BUFF
    ldx #$0
    jsr GETTOKEN
CFL:lda (CURLINE_L), y
    sta TOKEN_BUFF, x
    inx
    beq ERR
    iny
    beq ERR
    cmp #';'                ; semicolon needs to be included in the function def
    beq SAVE_FUNC
    jmp CFL
SAVE_FUNC:
    ldx #$0
    ldy #$0
    lda (NEXT_USER_L), y
    adc #$2
    tay
SFL:lda TOKEN_BUFF, x
    sta (NEXT_USER_L), y
    inx
    iny
    cmp #';'
    beq SAVE_NEXT_POINTER
    jmp SFL
SAVE_NEXT_POINTER:          
    lda #$0
    sta (NEXT_USER_L), y
    iny                     ; Y register now contains the offset to the next
    lda #$0                 ;   availaible area in RAM. 
    sta (NEXT_USER_L), y    ; Zero out the next address to terminate user list lookup
    lda NEXT_USER_H         ; Copy this so we can set the pointer
    sta LL_CURH
    tya
    clc
    adc NEXT_USER_L         ; add offset to base pointer
    sta LL_CURL             ; borrow this again
    bcc NO_CARRY
    inc LL_CURH
NO_CARRY:                   ; LL_CURL/H now contains the full pointer to the next area
    ldy #$0                 ;   of RAM or next node
    lda (NEXT_USER_L), y    ; Get funciton name size again for the func we just wrote
    adc #$1
    tay                     ; Y now has the offset for the next node pointer in node
    lda LL_CURL
    sta (NEXT_USER_L), y
    iny
    lda LL_CURH
    sta (NEXT_USER_L), y
    lda LL_CURL
    sta NEXT_USER_L
    lda LL_CURH
    sta NEXT_USER_H
    jmp MAIN 
ERR:ldx #<DEF_ERRS
    ldy #>DEF_ERRS
    jsr PRINTS
    ldy #$0
    lda #$0
    sta (NEXT_USER_L), y
    jmp MAIN
.)


F_RETURN: .(
    lda IN_FUNCTION
    beq ERR
    dec IN_FUNCTION
    pla
    sta CURLINE_IDX
    pla
    sta CURLINE_H
    pla
    sta CURLINE_L
    jmp FUNC_END
ERR:ldx #<NOT_IN_FUNCS
    ldy #>NOT_IN_FUNCS
    jsr PRINTS
    jmp MAIN
.)


