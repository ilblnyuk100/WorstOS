space_skipper:
	mov byte [process_num], 7
	push es
	mov ax, 0xb800
	mov es, ax
	mov ax, [es:di]
	cmp al, 0x20
	je .space_skip
	cmp al, 0
	je .ignore
	pop es
	ret

.space_skip:
	add di, 2
	mov ax, [es:di]
	cmp al, 0x20
	je .space_skip
	cmp al, 0
	je .ignore
	pop es
	ret

.ignore:
	mov byte [ignore_subparser], 1
	pop es
	ret

ignore_subparser db 0

