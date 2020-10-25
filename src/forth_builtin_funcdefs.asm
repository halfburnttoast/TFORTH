; BUILT-IN FUNCTIONS
; Called via function pointer in linked-list
#ifdef PARN_IGNORE
F_IGNORE:
    jmp FUNC_END
#endif

; The 6502 does not support indirect subroutines calls
; so this function does the work needed to emulate one
F_CALL: .(
    _PUSH_FRAME
    lda #<CALL_RETURN       ; return addresses are pushed in reverse order
    ldx #>CALL_RETURN
    sec
    sbc #$1                 ; on return, RTS automatically increments the PC by 1
    bcs NO_CARRY
    dex
NO_CARRY:
    clc
    phx                     ; push the return address to allow RTS to work
    pha
    lda ARGA
    ldx ARGX
    ldy ARGY
    jmp (EXT_MEM_L)
CALL_RETURN:                ; the next RTS call will fall to this label
    _PULL_FRAME 
    jmp FUNC_END
.)

F_ARGX:
    jsr STACK_POP
    sta ARGX
    jmp FUNC_END

F_ARGY:
    jsr STACK_POP
    sta ARGY
    jmp FUNC_END

F_ARGA:
    jsr STACK_POP
    sta ARGA
    jmp FUNC_END

; EXT_MEM_L
; EXT_MEM_H
F_EXML_SET: .(
    jsr STACK_POP
    sta EXT_MEM_L
    jmp FUNC_END 
.)

F_EXML_GET: .(
    lda EXT_MEM_L
    jsr STACK_PUSH
    jmp FUNC_END
.)

F_EXMH_SET: .(
    jsr STACK_POP
    sta EXT_MEM_H
    jmp FUNC_END
.)

F_EXMH_GET: .(
    lda EXT_MEM_H
    jsr STACK_PUSH
    jmp FUNC_END
.)

F_EXMP_INC: .(
    inc EXT_MEM_L
    bne NC
    inc EXT_MEM_H
NC: jmp FUNC_END
.)

F_EXMP_DEC: .(
    dec EXT_MEM_L
    lda #$FF
    cmp EXT_MEM_L
    bne NC
    dec EXT_MEM_H
NC: jmp FUNC_END
.)

F_EXM_READ: .(
    phy
    ldy #$0
    lda (EXT_MEM_L), y
    ply
    jsr STACK_PUSH
    jmp FUNC_END
.)

F_EXM_WRITE: .(
    jsr STACK_POP
    phy
    ldy #$0
    sta (EXT_MEM_L), y
    ply
    jmp FUNC_END
.)

; Removes a function from USER_LIST.
; First seeks function location by name
; Then seeks starting location of next function
;   If no next function, sets deleted functions name length to 0
;   and relocates NEXT_USER_H/L to that new 0
; If function next function is found
;   Overwrite deleted function by moving entire USER_LIST down
;   Null terminated
F_DELETE: .(
    jsr GETTOKEN       ; get name of function to be deleted
    jsr COPY_TOKEN      ; copy that into TOKEN_BUFF
    lda #<USER_FUNC
    sta LL_CURL
    lda #>USER_FUNC
    sta LL_CURH
    jsr USER_SEEK 
    beq NOT_FOUND

    ; function found, check if there is a function directly after it in memory
    ; keep the to-be-deleted function pointer in LL_CURL/H
    
    ; calculate nextnode pointer, store in B16L/H (borrowed)
    lda LL_CURL
    sta B16L
    lda LL_CURH
    sta B16H
    ldy #$0             ; fetch offset from node
    lda (LL_CURL), y    ;   "
    clc
    adc #$1             ;   "
    tay                 ;   "
    lda (LL_CURL), y    ;   "
    clc
    adc LL_CURL
    sta B16L
    bcc NC
    inc B16H
    clc
NC:                     ; B16L/H now contains the absolute nextnode pointer
    ldy #$0
    lda (B16L), y       ; fetch first byte from nextnode (length bit)
    beq TOP_FUNCTION    ; if length is zero, this is the top function in the list

    ; not the top function. Overwrite function with definitons above it
COPY_LOOP:
    lda (B16L), y
    sta (LL_CURL), y
    cmp #$0
    beq END
    clc
    lda LL_CURL
    adc #$1
    sta LL_CURL
    bcc LNC
    inc LL_CURH
    clc
LNC:lda B16L
    adc #$1
    sta B16L
    bcc BNC
    inc B16H
    clc
BNC:bra COPY_LOOP
TOP_FUNCTION:
END:
    lda #$0
    sta (LL_CURL), y    ; null out length byte of function to be deleted
    lda LL_CURL         ; set NEXT_USER_L/H to the byte we just nulled out
    sta NEXT_USER_L     ;   this will cause the next function def to overwrite this
    lda LL_CURH         ;   function. No further action needed. 
    sta NEXT_USER_H
    jmp FUNC_END 
NOT_FOUND:
    ldx #<NFS
    ldy #>NFS
    jsr PRINTS
    jmp MAIN
NFS:    .byte   "FUNCTION NOT FOUND",0
.)

F_EQ0: .(
    jsr STACK_POP
    cmp #$0
    beq ZERO
    lda #$0
E:  jsr STACK_PUSH
    jmp FUNC_END
ZERO:
    lda #$FF
    bra E
.)

F_ISNEG: .(
    jsr STACK_POP
    and #$80
    cmp #$0
    bne POS
    lda #$0
E:  jsr STACK_PUSH
    jmp FUNC_END
POS:lda #$FF
    bra E
.)

F_SIGNED_OUT: .(
    jsr STACK_POP
    pha
    and #$80
    beq NOT_NEG
    pla
    and #$7F
    sta TEMP
    dec TEMP
    lda #'-'
    sta CHAROUT
    lda #$7F
    sec
    sbc TEMP
    jsr STACK_PUSH
    jmp F_PRINT
NOT_NEG:
    pla
    jsr STACK_PUSH
    jmp F_PRINT
.)

F_HEXIN: .(
    jsr GETTOKEN    ; get next token from line input
    ldy CURLINE_IDX
    stz TEMP
L:  lda (CURLINE_L), y
    beq END
    cmp #' '
    beq END
    jsr CTON
    tax
    lda TEMP
    _ROL4
    sta TEMP
    txa
    ora TEMP
    sta TEMP
    iny
    jmp L
END:
    lda TEMP
    jsr STACK_PUSH
    iny
    sty CURLINE_IDX
    jmp FUNC_END
.)

F_HEXOUT: .(
    jsr STACK_POP
    jsr BTOA
    sta CHAROUT
    sty CHAROUT
    lda #' '
    sta CHAROUT
    jmp FUNC_END
.)


F_WORDS: .(
    ldx #<BIS
    ldy #>BIS
    jsr PRINTS
    jsr NEWLINE  
    jsr NEWLINE
    lda #<LL_ROOT_NODE
    sta LL_CURL
    lda #>LL_ROOT_NODE
    sta LL_CURH
SYSTEM_TRANSVERSE:
    ldy #$0
    lda (LL_CURL), y
    beq ST_END
    tax
ST_LOOP:
    iny
    lda (LL_CURL), y
    sta CHAROUT
    dex
    bne ST_LOOP
    lda #' '
    sta CHAROUT
    iny 
    lda (LL_CURL), y
    tax
    iny
    lda (LL_CURL), y
    sta LL_CURH
    stx LL_CURL
    jmp SYSTEM_TRANSVERSE
ST_END:
    jsr NEWLINE
    jsr NEWLINE
    ldx #<UDS
    ldy #>UDS
    jsr PRINTS
    jsr NEWLINE  
    jsr NEWLINE
    lda #<USER_FUNC
    sta LL_CURL
    lda #>USER_FUNC
    sta LL_CURH
USER_TRANSVERSE:
    ldy #$0
    lda (LL_CURL), y
    beq UT_END
    tax
UT_LOOP:
    iny
    lda (LL_CURL), y
    sta CHAROUT
    dex
    bne UT_LOOP
    lda #' '
    sta CHAROUT
    iny
    lda (LL_CURL), y
    clc
    adc LL_CURL
    sta LL_CURL
    bcc USER_TRANSVERSE
    inc LL_CURH
    clc
    jmp USER_TRANSVERSE
UT_END:
    jmp FUNC_END 
BIS: .byte   "BUILT-IN FUNCTIONS:",0
UDS: .byte   "USER FUNCTIONS:",0
.)


F_RANDOM:
    lda RANDOM
    jsr STACK_PUSH
    jmp FUNC_END

F_DROP_ALL:
    stz STACK_OFFSET
    jmp FUNC_END

; push current loop limit to stack
F_LOOP_GET_LIMIT: .(
    lda IN_LOOP
    beq ERR
    lda LOOP_LIMIT
    jsr STACK_PUSH
    jmp FUNC_END
ERR:ldx #<LOOP_ERRS
    ldy #>LOOP_ERRS
    jsr PRINTS
    jmp MAIN
.)

; fetch outer loop index if available and push to stack
F_LOOP_J: .(
    lda IN_LOOP
    cmp #$1             ; there must be at least two loops running for this to work
    bcc ERR
    beq ERR
    lda LOOP_OUTER_IDX  ; this is set when a nested DO loop starts
    jsr STACK_PUSH
    jmp FUNC_END
ERR:ldx #<NEST_LOOP_ERRS
    ldy #>NEST_LOOP_ERRS
    jsr PRINTS
    jmp MAIN
.)

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
    adc #$1
    adc LL_CURL
    sta LL_CURL
    bcc NO_CARRY
    inc LL_CURH
NO_CARRY:
    ldy #$0
L:  lda (LL_CURL), y
    sta CHAROUT
    iny
    cmp #';'
    bne L
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

F_VAR_INC: .(
    jsr STACK_POP
    tax
    inc VARIABLE_PAGE, x
    jmp FUNC_END
.)

F_VAR_DEC: .(
    jsr STACK_POP
    tax
    dec VARIABLE_PAGE, x
    jmp FUNC_END
.)

F_VAR_PRINT: .(
    jsr STACK_POP
    tax
    lda VARIABLE_PAGE, x
    jsr STACK_PUSH
    jmp F_PRINT
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

F_XOR: .(
    jsr STACK_POP
    sta TEMP
    jsr STACK_POP
    eor TEMP
    jsr STACK_PUSH
    jmp FUNC_END
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
    sta LOOP_OUTER_IDX          ; store for J command 
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
    beq ERR
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
;   1 byte  -   length of entire function def, used for calculating next node
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
SAVE_FUNC:                  ; copies function def from TOKEN_BUFF to final RAM location
    ldx #$0
    ldy #$0
    lda (NEXT_USER_L), y
    adc #$1                 ; move into area where function is defined
    tay                     ;   "
SFL:lda TOKEN_BUFF, x
    sta (NEXT_USER_L), y
    inx
    iny
    cmp #';'
    beq SAVE_NEXT_OFFSET
    jmp SFL
SAVE_NEXT_OFFSET:
    lda #$0                 ; terminate function def in RAM
    sta (NEXT_USER_L), y    ;   "
    phy
    ldy #$0
    lda (NEXT_USER_L), y
    tay
    iny
    pla
    sta (NEXT_USER_L), y
    clc
    adc NEXT_USER_L
    sta NEXT_USER_L
    bcc NO_CARRY
    inc NEXT_USER_H
    clc
NO_CARRY:
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


