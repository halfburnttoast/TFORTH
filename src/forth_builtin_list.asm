; LINKED LIST ROOT - Format:
; 1 byte  - length of command
; n bytes - string literal of command
; 2 bytes - pointer to next node in LL
; 2 bytes - function pointer to command
LL_ROOT_NODE:
#ifdef PARN_IGNORE
D_PARC:
    .byte $1
    .byte ")"
    .word D_PARO
    .word F_IGNORE
D_PARO:
    .byte $1
    .byte "("
    .word LL_NEXTNODE
    .word F_IGNORE
#endif
LL_NEXTNODE:             ; add new entries after this label
D_SEE:
    .byte $3
    .byte "SEE"
    .word D_ROT
    .word F_SEE
D_ROT:
    .byte $3
    .byte "ROT"
    .word D_OVER
    .word F_ROT
D_OVER:
    .byte $4
    .byte "OVER"
    .word D_NOBLOCK_KEY
    .word F_OVER
D_NOBLOCK_KEY:
    .byte $4
    .byte "KEY@"
    .word D_VAR_READ
    .word F_NOBLOCK_KEY
D_VAR_READ:
    .byte $1
    .byte "@"
    .word D_VAR_WRITE
    .word F_VAR_READ
D_VAR_WRITE:
    .byte $1
    .byte "!"
    .word D_WHILE
    .word F_VAR_WRITE
D_WHILE: 
    .byte $5
    .byte "WHILE"
    .word D_BEGIN
    .word F_WHILE
D_BEGIN: 
    .byte $5
    .byte "BEGIN"
    .word D_EMIT
    .word F_BEGIN
D_EMIT:
    .byte $4
    .byte "EMIT"
    .word D_KEY
    .word F_EMIT
D_KEY:
    .byte $3
    .byte "KEY"
    .word D_INVERT
    .word F_KEY
D_INVERT:
    .byte $6
    .byte "INVERT"
    .word D_OR
    .word F_INVERT
D_OR: 
    .byte $2
    .byte "OR"
    .word D_AND
    .word F_OR
D_AND:
    .byte $3
    .byte "AND"
    .word D_LT
    .word F_AND
D_LT:
    .byte $1
    .byte "<"
    .word D_GT
    .word F_LT
D_GT:
    .byte $1
    .byte ">"
    .word D_EQ
    .word F_GT
D_EQ:
    .byte $1
    .byte "="
    .word D_SUB
    .word F_EQ
D_SUB:
    .byte $1
    .byte "-"
    .word D_THEN
    .word F_SUB
D_THEN:
    .byte $5
    .byte ".THEN"
    .word D_ELSE
    .word F_THEN
D_ELSE:
    .byte $5
    .byte ".ELSE"
    .word D_IF
    .word F_ELSE
D_IF:
    .byte $2
    .byte "IF"
    .word D_LOOP_I
    .word F_IF
D_LOOP_I:
    .byte $1
    .byte "I"
    .word D_LOOP
    .word F_LOOP_I
D_LOOP:
    .byte $4
    .byte "LOOP"
    .word D_DO
    .word F_LOOP
D_DO:
    .byte $2
    .byte "DO"
    .word D_DROP
    .word F_DO
D_DROP
    .byte $4
    .byte "DROP"
    .word D_SWAP
    .word F_DROP
D_SWAP:
    .byte $4
    .byte "SWAP"
    .word D_MOD
    .word F_SWAP
D_MOD:
    .byte $3
    .byte "MOD"
    .word D_DIV
    .word F_MOD
D_DIV:
    .byte $1
    .byte "/"
    .word D_MULT
    .word F_DIV
D_MULT:
    .byte $1
    .byte "*"
    .word D_CR
    .word F_MULT
D_CR
    .byte $2
    .byte "CR"
    .word D_STR
    .word F_CR
D_STR:
    .byte $2
    .byte ".",$22
    .word D_DUP
    .word F_STR
D_DUP:
    .byte $3
    .byte "DUP"
    .word D_RETURN
    .word F_DUP
D_RETURN:
    .byte $1
    .byte ";"
    .word D_DEFINE
    .word F_RETURN
D_DEFINE:
    .byte $1
    .byte ":"
    .word D_ADD
    .word F_DEFINE
D_ADD
    .byte $1
    .byte "+"
    .word D_PRINT
    .word F_ADD
D_PRINT:
    .byte $1
    .byte "."
    .word D_DUMP
    .word F_PRINT
D_DUMP:
    .byte $4
    .byte "DUMP"
    .word D_TEST
    .word F_DUMP
D_TEST:
    .byte $4
    .byte "QUIT"
    .word D_END
    .word F_QUIT
D_END:
    .byte $0


