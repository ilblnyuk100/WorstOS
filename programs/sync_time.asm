sync_time:
	push di
	push ax
	.check:
	sendToPort 0x70, 0x0A
	getFromPort al, 0x71
	test al, 0b10000000
	jnz .check
	sendToPort 0x70, 0x02
	getFromPort al, 0x71
	mov byte [minutes], al
	sendToPort 0x70, 0x04
	getFromPort al, 0x71
	mov byte [hours], al
	sendToPort 0x70, 0x07
	getFromPort al, 0x71
	mov byte [day], al
	sendToPort 0x70, 0x08
	getFromPort al, 0x71
	mov byte [month], al
	sendToPort 0x70, 0x09
	getFromPort al, 0x71
	mov byte [year], al
	

	mov di, 128
	putChar '2', 0x1e, di
	putChar '0', 0x1e, di

	mov ax, [year]
	call .convert_and_print


	putChar '/', 0x1e, di

	mov ax, [month]
	call .convert_and_print

	putChar '/', 0x1e, di

	mov ax, [day]
	call .convert_and_print

	putChar ' ', 0x1e, di

	mov ax, [hours]
	call .convert_and_print

	putChar ':', 0x1e, 154

	mov ax, [minutes]
	call .convert_and_print

	pop ax
	pop di
	ret

.convert_and_print:
	push ax
	shr al, 4
	add al, 0x30
	putChar al, 0x1e, di
	pop ax
	and al, 0b00001111
	add al, 0x30
	putChar al, 0x1e, di
	ret 

minutes db 0
hours db 0
day db 0
month db 0
year db 0
