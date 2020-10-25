# TFORTH

A weird, ROMable, fully-interpreted Forth implementation for my custom 65C02 SBC.

This implementation of Forth is mainly just a programming exercise for me. I've never used Forth before, but wanted to be able to develop programs from the computer itself. Other, and frankly better, versions of Forth exist for the 6502. But, the architecture of my SBC is odd enough that porting existing Forths hasn’t worked too well. 

So, this is a written-from-scratch version of Forth that is in no way compliant to ANSI standards. There is no compiling mode. All statements and functions are interpreted on-the-fly. You can define functions, but they are stored as a substring in a linked-list in RAM.

Supports many standard Forth things, but does not yet support variables or arrays (and possibly other things I don’t know about yet). I’ll be adding more functionality as I learn more about the language. 

The IO handling routines are unique to my SBC. My SBC uses an Arduino nano for serial IO which does not have (or emulate) a command or status register. It should be able to be ported fairly easily by modifying the IO routines. 
