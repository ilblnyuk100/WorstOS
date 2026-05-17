[bits 16]

kbd:
	push ax
	getFromPort al, 0x60


	mov ah, al
	and al, 0b00001111
	shr ah, 4

.high:
	cmp ah, 9
	jle .numh
	jg .letterh

.numh:
	add ah, 0x30
	putChar ah, 0x07, 0
	jmp .low

.letterh:
	add ah, 0x41-10
	putChar ah, 0x07, 0
	jmp .low

.low:
	cmp al, 9
	jle .numl
	jg .letterl

.numl:
	add al, 0x30
	putChar al, 0x07, 2
	jmp .end

.letterl:
	add al, 0x41-10
	putChar al, 0x07, 2
	jmp .end

.end:
	pop ax
	eoiMaster
	iret	
