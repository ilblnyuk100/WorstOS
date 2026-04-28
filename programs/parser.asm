shell_parser:

.find_start_offset:
	push di
	push ax
	push es
	push si
	mov si, shell_cmds
	mov ax, 0xb800
	mov es, ax
	sub di, 160
	sub di, [scroll_counter]
	.loop:
		mov ax, [es:di]
		cmp al, 0xff
		je .skip_1
		add di, 2
		jmp .loop
	.skip_1:
	add di, 2
	mov ax, [es:di]
	cmp al, 0
	je .ignore
	cmp al, '/'
	je .checking_comment
	cmp al, 0x20
	jne .skip_2
	.space_skip:
		add di, 2
		mov ax, [es:di]
		cmp al, 0x20
		je .space_skip
		cmp al, 0
		je .ignore
		cmp al, '/'
		je .checking_comment
	.skip_2:
	mov [start_command_offset], di


.comparing:
	mov ax, [es:di]
	cmp al, [ds:si]
	jne .comp_err
	inc si
	cmp byte [ds:si], 0
	je .comp_complete
	add di, 2
	jmp .comparing

.comp_complete:
	add di, 2
	mov [end_command_offset], di
	mov ax, [es:di]
	cmp al, 0
	jne .checking_space
.comp_complete_skip:
	sub di, 2
	inc si
	mov al, [ds:si]
	mov [process_num], al
	pop si
	pop es
	pop ax
	pop di
	ret

.comp_err:
	inc si
	cmp byte [ds:si], 0
	jne .comp_err
	add si, 2
	cmp byte [ds:si], 0xff
	je .not_found
	mov di, [start_command_offset]
	jmp .comparing

.not_found:
	pop si
	pop es
	pop ax
	pop di
	print shell_cmd_not_found_msg, 0x0c, di
	mov byte [shell_parser_err], 1
	ret

.ignore:
        pop si
        pop es
        pop ax
        pop di
        mov byte [shell_parser_ignore], 1
        ret

.checking_space:
	cmp al, 0x20
	je .comp_complete_skip
	jmp .not_found	

.checking_comment:
	add di, 2
	mov ax, [es:di]
	cmp al, '/'
	je .ignore
	sub di, 2
	mov [start_command_offset], di
	jmp .comparing

shell_cmds:
	db "test1", 0, 3
	db "test2", 0, 4
	db "clearscr", 0, 5
	db "reboot", 0, 6
	db "wth", 0, 8
	db 0xff

start_command_offset dw 0
end_command_offset dw 0

shell_parser_ignore db 0
shell_parser_err db 0
shell_cmd_not_found_msg db "Parser can't find this command", 0
