all:
	xa -o forth.rom forth.asm

clean:
	rm -f *.rom
	rm -f memdump
