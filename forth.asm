//#define PRELOAD_TEST_FUNCTION
//#define TEST_PARSE
//#define NO_TITLE
//#define PARN_IGNORE
//#define RAM_LOAD

#ifdef RAM_LOAD
    * = $2000
#else
    * = $E288
#endif

#define _PUSH_FRAME \
    pha         :   \
    phx         :   \
    phy         :   \
    php

#define _PULL_FRAME \
    plp         :   \
    ply         :   \
    plx         :   \
    pla

#define _ROL4   \
    rol     :   \
    rol     :   \
    rol     :   \
    rol


; system vectors
CHAROUT             = $8001
CHARIN              = $8002
RANDOM              = $8003

; ZP variables
B16L                = $0
B16H                = $1
PRL                 = $2
PRH                 = $3
STACK_OFFSET        = $4
LINE_IN_IDX         = $5
TEMP                = $6
CURWORD_IDX         = $7
WORD_LEN            = $8
MULT_TEMP           = $9
DIV_TEMP            = $A
WORD_PTRL           = $B 
WORD_PTRH           = $C
LL_ROOTL            = $D
LL_ROOTH            = $E
LL_CURL             = $F
LL_CURH             = $10
YSTORE              = $11
NUM_CONV            = $12
NUM_CONV_2          = $13
NUM_CONV_HEX        = $14
XSTORE              = $15
CURLINE_L           = $16
CURLINE_H           = $17
CURLINE_IDX         = $18
NEXT_USER_L         = $19       ; pointer to next available address for user funcitons
NEXT_USER_H         = $1A       ;  "
IN_FUNCTION         = $1B
IN_LOOP             = $1C
LOOP_BEGIN_IDX      = $1D
LOOP_COUNT          = $1E
LOOP_LIMIT          = $1F
IN_IF_BLOCK         = $20
IN_WHILE_LOOP       = $21
WHILE_LOOP_IDX      = $22
LOOP_OUTER_IDX      = $23
EXT_MEM_L           = $24
EXT_MEM_H           = $25
ARGA                = $26
ARGX                = $27
ARGY                = $28

; buffers
LINE_IN             = $0200     ; 0200 - 0300
STACK               = $0300     ; 0300 - 0400
TOKEN_BUFF          = $0500     ; 0400 - 040F
VARIABLE_PAGE       = $0600
USER_FUNC           = $0700     ; arbitrary for now

INIT: .(
    clc
    stz STACK_OFFSET
    lda #<USER_FUNC     ; Reset pointer to next available address in RAM for
    sta NEXT_USER_L     ;   user function definitions.
    lda #>USER_FUNC     ;   "
    sta NEXT_USER_H     ;   "
#ifndef NO_TITLE
    jsr NEWLINE
    ldx #<TITLE
    ldy #>TITLE
    jsr PRINTS
#endif
BAD_OPTION:
    jsr NEWLINE
    ldx #<WCS
    ldy #>WCS
    jsr PRINTS
L:  lda CHARIN
    sta CHAROUT
    beq L
    cmp #'W'
    beq WARM
    cmp #'C'
    beq COLD
    jmp BAD_OPTION
WARM:
    jsr STARTUP_WARM
    bra WC_END
COLD:
    stz USER_FUNC
WC_END:
    jmp MAIN
WCS:    .byte   "WARM/COLD?: ",0
#ifdef PRELOAD_TEST_FUNCTION
.(              ; FUNCTION DEF BLOCK MUST BE TERMINATED BY $
    ldy #$0
L:  lda TF, y
    cmp #'$'
    beq E
    sta (NEXT_USER_L), y
    iny
    jmp L
E:  lda #$0C
    sta NEXT_USER_L
    lda #$06
    sta NEXT_USER_H
    jmp MAIN
TF: .byte   $1, 'X'
    .byte   $6
    .byte   "0 ;"
    .byte   $1, 'Y'
    .byte   $6
    .byte   "1 ;",$0,"$"
.)
#endif
.)

MAIN:
    ldx #$FF
    txs
    stz IN_FUNCTION
    stz IN_LOOP
    stz IN_WHILE_LOOP
    stz LINE_IN_IDX
    stz CURLINE_IDX
    stz IN_IF_BLOCK
#ifdef TEST_PARSE
TEST: .(
    ldx #<CMD
    ldy #>CMD
    jsr PARSE_LINE
    brk
CMD:    .byte   "DELETE X",0
.)
#endif
    jsr GETLINE
    jsr NEWLINE
    ldx #<LINE_IN
    ldy #>LINE_IN
    jsr PARSE_LINE
    jmp MAIN



; Parse the string line at (X, Y), 
PARSE_LINE:
#print PARSE_LINE
    stx CURLINE_L
    sty CURLINE_H
    ldy #$0
FUNC_END:
#print FUNC_END
NEXT: .(                ; parse next token in line
    ldy CURLINE_IDX
    jsr GETTOKEN
    bne N 
    jmp EOL             ; if at EOL, end parsing
N:  jsr COPY_TOKEN
    lda #<LL_ROOT_NODE
    sta LL_CURL
    lda #>LL_ROOT_NODE
    sta LL_CURH
SEEK:                   ; begin linked list lookup
    ldy #$0
    lda (LL_CURL), y    ; fetch top byte from LL node
    beq NOT_BUILTIN_WORD;   if zero, it's the end of the list
    cmp WORD_LEN        ; compare to token length
    bne SKIP            ;   skip to next node in list if not equal
CHECK:                  ; command length matches length of token
    clc
    tax
    tay
    dex                 ; Remove one from X (len(token) - 1)
CHECK_LOOP:             ; compare strings in reverse
    lda (LL_CURL), y
    cmp TOKEN_BUFF, x
    bne SKIP
    dey
    cpy #$0
    beq FOUND
    dex
    jmp CHECK_LOOP
FOUND:
    clc
    lda WORD_LEN        ; get function pointer from LL node
    adc #$3             ;  "
    tay
    lda (LL_CURL), y
    sta WORD_PTRL       ; store function pointer 
    iny
    lda (LL_CURL), y
    sta WORD_PTRH
    jmp (WORD_PTRL)     ; now jump to function pointer
SKIP:
    clc
    ldy #$0
    lda (LL_CURL), y
    adc #$1
    tay
    lda (LL_CURL), y
    tax
    iny
    lda (LL_CURL), y
    sta LL_CURH
    stx LL_CURL
    jmp SEEK
NOT_BUILTIN_WORD:       ; check for user-defined function
#print NOT_BUILTIN_WORD
    lda #<USER_FUNC
    sta LL_CURL
    lda #>USER_FUNC
    sta LL_CURH
    jsr USER_SEEK
    beq NOT_WORD
    jmp RUN_SUBSTRING
    

NOT_WORD:               ; try to interpret token as integer
#print NOT_WORD
    ldy #$0             ; reload the first character of the token
    stz NUM_CONV_HEX
L:  lda TOKEN_BUFF, y
    cmp #SPACE
    beq END
    cmp #$0
    beq END
    cmp #CR
    beq END
    cmp #LF
    beq END
    pha
    lda NUM_CONV_HEX    ; convert decimal input into hex for storage
    ldx #$A
    clc
    jsr MULT
    sta NUM_CONV_HEX
    pla
    jsr CTON
    cmp #$0
    bmi ERR
    cmp #$A
    bcs ERR
    clc
    adc NUM_CONV_HEX
    sta NUM_CONV_HEX
    iny
    jmp L
END:
    lda NUM_CONV_HEX
    jsr STACK_PUSH
    jmp FUNC_END
ERR:
    jmp BAD_WORD
EOL:lda IN_WHILE_LOOP
    beq EOL1
    jmp LOOP_END_MISSING
EOL1:
    lda IN_LOOP
    beq EOL2
    jmp LOOP_END_MISSING
EOL2:
    rts
BAD_WORD:
    lda #ERRC
    sta CHAROUT
    jmp MAIN
.)


; This function is called from the main interpreter loop, F_SEE, F_DELETE
USER_SEEK: .(
    ldy #$0
    lda (LL_CURL), y  ; seek through the RAM list for a custom function
    beq NOT_FOUND     ; if function name length == 0, stop seeking
    cmp WORD_LEN
    bne USER_SKIP
USER_CHECK:
    clc
    tax
    tay
    dex
USER_CHECK_LOOP:
    lda (LL_CURL), y
    cmp TOKEN_BUFF, x
    bne USER_SKIP
    dey
    cpy #$0
    beq FOUND
    dex
    jmp USER_CHECK_LOOP
USER_SKIP:
    clc
    ldy #$0
    lda (LL_CURL), y    ; fetch offset from link-list to next node
    adc #$1
    tay
    lda (LL_CURL), y
    clc
    adc LL_CURL
    sta LL_CURL
    bcc NO_CARRY
    inc LL_CURH
    clc
NO_CARRY:
    jmp USER_SEEK
NOT_FOUND:
    lda #$0
    rts
FOUND:
    lda #$1
    rts
.)

; reloads user function list. Scans through USER_LIST until it finds 
; a null terminator. This null terminator is NEXT_USER_L/H
STARTUP_WARM: .(
    ldy #$0
SEEK_LOOP:
    lda (NEXT_USER_L), y
    beq END
    clc
    inc NEXT_USER_L
    bne NO_CARRY
    inc NEXT_USER_H
    clc
NO_CARRY:
    jmp SEEK_LOOP
END:rts
.)

#include "src/ascii_const.asm"
#include "src/getline.asm"
#include "src/util.asm"
#include "src/prints.asm"
#include "src/gettoken.asm"
#include "src/forth_builtin_list.asm"
#include "src/forth_strings.asm"
#include "src/forth_utils.asm"
#include "src/forth_builtin_funcdefs.asm"


