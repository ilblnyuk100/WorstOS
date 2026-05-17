enable_disable_parser:
	push es
	push di
	push si
	push ax
	mov di, [end_command_offset]
	call space_skipper
	cmp byte [ignore_subparser], 1
	je .err_no_arg
	mov ax, 0xb800
	mov es, ax
	mov si, enable_disable_args

	.loop:
		mov bx, [es:di]
		lodsb
		cmp al, 0
		je .complete
		cmp al, bl
		jne .retry
		add di, 2
		jmp .loop

	.retry:
		inc si
		cmp byte [ds:si], 0xff
		je .err_inv_arg
		cmp byte [ds:si], 'd'
		je .loop
		jmp .retry

	.complete:
		cmp bl, 0
		jne .check_space
		lodsb
		mov byte [arg_endisable_id], al
		jmp .exit

	.check_space:
		cmp bl, 0x20
		jne .err_inv_arg
		call space_skipper
		cmp byte [ignore_subparser], 1
		jne .err_inv_arg
		mov byte [ignore_subparser], 0
		lodsb
		mov byte [arg_endisable_id], al
		jmp .exit

	.err_no_arg:
		pop ax
		pop si
		pop di
		pop es
		mov byte [ignore_subparser], 0
		print endis_err_no_arg_msg, 0x0c, di
		ret

	.err_inv_arg:
		pop ax
		pop si
		pop di
		pop es
		print endis_err_inv_arg_msg, 0x0c, di
		ret

	.exit:
		pop ax
		pop si
		pop di
		pop es
		ret

enable_disable_args:
	db "enable", 0, 1
	db "disable", 0, 2
	db 0xff

arg_endisable_id db 0

endis_err_no_arg_msg db "command requires an argument", 0
endis_err_inv_arg_msg db "invalid argument", 0
