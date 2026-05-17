[bits 16]

test1:
	print test1_msg, 0x07, di
	scrollDown
	sub word [end_command_offset], 160
	sub word [start_command_offset], 160
	mov di, 3840
	print test1_msg_1, 0x07, di
	push ax
	mov ax, [start_command_offset]

.convert:
	push dx
	push cx
	push bx

	.divide_loop:
		xor dx, dx
		mov bx, 10
		div bx
		
		; int 165
		; dx 5; ax 16
		; dx 6; ax 1
		; dx 1; ax 0

		inc cx
		push dx
		cmp ax, 0
		jne .divide_loop
		
		
	.print_loop:
		pop dx
		add dl, 0x30
		putChar dl, 0x07, di
		loop .print_loop
	
	pop bx
	pop cx
	pop dx
	pop ax

	cmp byte [test1_done], 1
	je .skip_1

	scrollDown
	sub word [end_command_offset], 160
	sub word [start_command_offset], 160
	mov di, 3840
	print test1_msg_2, 0x07, di
	mov byte [test1_done], 1
	push ax
	mov ax, [end_command_offset]
	jmp .convert

.skip_1:
	mov byte [test1_done], 0
	mov di, [end_command_offset]
	call space_skipper
	mov byte [process_num], 3
	push es
	cmp byte [ignore_subparser], 1
	je .exit
	mov ax, 0xb800
	mov es, ax
	mov ax, [es:di]
	cmp al, 'z'
	je .arg
	jmp .error_subparser

.exit:
	pop es
	mov byte [ignore_subparser], 0
	ret

.arg:
	add di, 2
	call space_skipper
	mov ax, [es:di]
	cmp al, 0
	jne .error_subparser
	scrollDown
	mov di, 3840
	print test1_msg_3, 0x0f, di	
	jmp .exit

.error_subparser:
	scrollDown
	mov di, 3840
	print test1_err_msg, 0x0c, di
	jmp .exit

test2:
	print test2_msg, 0x07, di
	ret

test1_msg db "Yeah.. It's the test 1. Your worst parser works", 0
test1_msg_1 db "Command Starts at: ", 0
test1_msg_2 db "Command End at: ", 0
test1_msg_3 db "Argument 'z'", 0
test1_err_msg db "Unknown argument", 0
test1_done db 0
test2_msg db "And it's the test 2. Your parser works ", 0x02, 0
