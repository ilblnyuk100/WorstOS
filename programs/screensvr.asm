[bits 16]

screensvr:
	cmp byte [screensvr_status], 0
	jne .skip
	ret
.skip:
	mov word [screensvr_counter], 0
	push ds
	push es
	push di
	push si
	push cx
	push ax

	push ds

	mov di, screensvr_buffer
	mov ax, ds
	mov es, ax
	mov ax, 0xb800
	mov ds, ax
	mov si, 0
	mov cx, 2000
	cld
	rep movsw

	pop ds

	fillAllScreen 0x00, 0x07
	print screensvr_msg, 0x08, 1984
	setCursorPos
	sleep 1000
	print screensvr_msg, 0x07, 1984
	sleep 1000
	print screensvr_msg, 0x0f, 1984

	.halt:
		mov byte [int_from_pit], 0
		mov word [screensvr_counter], 0
		hlt
		cmp byte [int_from_pit], 1
		je .halt

	mov ax, 0xb800
	mov es, ax
	mov si, screensvr_buffer
	mov di, 0
	mov cx, 2000
	cld
	rep movsw

	pop ax
	pop cx
	pop si
	pop di
	setCursorPos
	pop es
	pop ds
	mov byte [screensvr_status], 0
	ret	

screensaver_command:
	call enable_disable_parser
	cmp byte [arg_endisable_id], 1
	je .enable
	cmp byte [arg_endisable_id], 2
	je .disable
	ret

	.disable:
		mov byte [arg_endisable_id], 0
		push es
		push di
		push ax
		mov di, sys_config_buffer
		inc di
		mov ax, ds
		mov es, ax
		mov byte [es:di], 1
		mov ax, OS_SIZE_IN_SECTORS - 1
		loadToDisk al, ah, 0, 0, 1, ds, sys_config_buffer
		pop ax
		pop di
		pop es
		print screensvr_disable_msg, 0x0c, di
		ret

	.enable:
		mov byte [arg_endisable_id], 0
		push es
		push di
		push ax
		mov di, sys_config_buffer
		inc di
		mov ax, ds
		mov es, ax
		mov byte [es:di], 0
		mov ax, OS_SIZE_IN_SECTORS - 1
		loadToDisk al, ah, 0, 0, 1, ds, sys_config_buffer
		pop ax
		pop di
		pop es
		print screensvr_enable_msg, 0x0a, di
		ret

screensvr_msg db "Where Are You? :3", 0
screensvr_buffer times 2000 dw 0
screensvr_disable_msg db "Screen Saver DISABLED", 0
screensvr_enable_msg db "Screen Saver ENABLED", 0
