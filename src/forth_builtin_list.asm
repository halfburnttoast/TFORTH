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
D_CALL:
    .byte $7
    .byte "EXMCALL"
    .word D_ARGX
    .word F_CALL
D_ARGX:
    .byte $5
    .byte "ARGX!"
    .word D_ARGY
    .word F_ARGX
D_ARGY:
    .byte $5
    .byte "ARGY!"
    .word D_ARGA
    .word F_ARGY
D_ARGA:
    .byte $5
    .byte "ARGA!"
    .word D_EXML_SET
    .word F_ARGA
D_EXML_SET:
    .byte $5
    .byte "EXML!"
    .word D_EXML_GET
    .word F_EXML_SET
D_EXML_GET:
    .byte $5
    .byte "EXML@"
    .word D_EXMH_SET
    .word F_EXML_GET
D_EXMH_SET:
    .byte $5
    .byte "EXMH!"
    .word D_EXMH_GET
    .word F_EXMH_SET
D_EXMH_GET:
    .byte $5
    .byte "EXMH@"
    .word D_EXMP_INC
    .word F_EXMH_GET
D_EXMP_INC:
    .byte $6
    .byte "EXMP++"
    .word D_EXMP_DEC
    .word F_EXMP_INC
D_EXMP_DEC:
    .byte $6
    .byte "EXMP--"
    .word D_EXM_READ
    .word F_EXMP_DEC
D_EXM_READ:
    .byte $4
    .byte "EXM@"
    .word D_EXM_WRITE
    .word F_EXM_READ
D_EXM_WRITE:
    .byte $4
    .byte "EXM!"
    .word D_DELETE
    .word F_EXM_WRITE
D_DELETE:
    .byte $6
    .byte "DELETE"
    .word D_EQ0
    .word F_DELETE
D_EQ0:
    .byte $2
    .byte "=0"
    .word D_ISNEG
    .word F_EQ0
D_ISNEG:
    .byte $4
    .byte "NEG?"
    .word D_SIGNED_OUT
    .word F_ISNEG
D_SIGNED_OUT:
    .byte $2
    .byte "S."
    .word D_HEXOUT
    .word F_SIGNED_OUT
D_HEXOUT:
    .byte $2
    .byte "$."
    .word D_HEXIN
    .word F_HEXOUT
D_HEXIN:
    .byte $1
    .byte "$"
    .word D_WORDS
    .word F_HEXIN
D_WORDS:
    .byte $5
    .byte "WORDS"
    .word D_RANDOM
    .word F_WORDS
D_RANDOM:
    .byte $6
    .byte "RANDOM"
    .word D_DROP_ALL
    .word F_RANDOM
D_DROP_ALL:
    .byte $7
    .byte "DROPALL"
    .word D_LOOP_GET_LIMIT
    .word F_DROP_ALL
D_LOOP_GET_LIMIT:
    .byte $2
    .byte "I'"
    .word D_LOOP_J
    .word F_LOOP_GET_LIMIT
D_LOOP_J:
    .byte $1
    .byte "J"
    .word D_SEE
    .word F_LOOP_J
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
    .word D_VAR_INC
    .word F_NOBLOCK_KEY
D_VAR_INC:
    .byte $3
    .byte "!++"
    .word D_VAR_DEC
    .word F_VAR_INC
D_VAR_DEC:
    .byte $3
    .byte "!--"
    .word D_VAR_PRINT
    .word F_VAR_DEC
D_VAR_PRINT:
    .byte $1
    .byte "?"
    .word D_VAR_READ
    .word F_VAR_PRINT
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
    .word D_XOR
    .word F_OR
D_XOR
    .byte $3
    .byte "XOR
    .word D_AND
    .word F_XOR
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


