[bits 16]

pic_init:
	push ax
	mov ax, 0x1000
	mov ds, ax
	mov es, ax
	pop ax
	
	initStack 0, 0xffff

	.icw1:
		sendToPort 0x20, 0b00010101	; M
		sendToPort 0xa0, 0b00010101	; S
	.icw2:
		sendToPort 0x21, 0x20		; M
		sendToPort 0xa1, 0x28		; S
	.icw3:
		sendToPort 0x21, 0b00000100	; M
		sendToPort 0xa1, 2		; S
	.icw4:
		sendToPort 0x21, 0b00000001	; M
		sendToPort 0xa1, 0b00000001	; S
	.ocw1:
		sendToPort 0x21, 0b11111000	; M
		sendToPort 0xa1, 0b11111111	; S
	
	push ax
	push es
	push di
	xor ax, ax
	mov es, ax
	mov di, 0x21*4
	mov word [es:di], kbd
	mov word [es:di+2], 0x1000
	mov di, 0x20*4
	mov word [es:di], pit
	mov word [es:di+2], 0x1000
	pop di
	pop es
	pop ax
	
	sendToPort 0x43, 0b00110100
	sendToPort 0x40, 0xa9
	sendToPort 0x40, 0x04
	
	sti
