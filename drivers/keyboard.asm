[bits 16]

kbd:
	mov word [screensvr_counter], 0
	mov byte [int_from_pit], 0
	cmp byte [screensvr_status], 1
	je .just_exit

	push ax			; Save registers
	push bx

	getFromPort al, 0x60	; Scan code -> al

	cmp al, 0xaa		; LShift break
	je .shift_unpressed
	cmp al, 0xb6		; RShift break
	je .shift_unpressed
	test al, 0b10000000
	jnz .exit

	cmp al, 0x2a		; LShift down
	je .shift_pressed
	cmp al, 0x36		; RShift down
	je .shift_pressed
	cmp al, 0x3a		; CapsLock down
	je .caps_pressed

	cmp al, 0x0e
	je .choose_backspace

	cmp al, 0x1c
	je .choose_enter

	cmp al, 0x48
	je .choose_up
	cmp al, 0x4b
	je .choose_left
	cmp al, 0x50
	je .choose_down
	cmp al, 0x4d
	je .choose_right

        cmp byte [capslock_shift_status], 1
        je .capslock_shift
	cmp byte [shift_status], 1
	je .shift
	cmp byte [capslock_status], 1
	je .capslock
	mov bx, std_table

	jmp .skip_1
	
	.shift:
		mov bx, shift_table
		jmp .skip_1
	
	.capslock:
		mov bx, caps_table
		jmp .skip_1
	
	.capslock_shift:
		mov bx, caps_shift_table
		jmp .skip_1

	 .shift_unpressed:
                mov byte [shift_status], 0
		mov byte [capslock_shift_status], 0
                jmp .exit

	.shift_pressed:
		mov byte [shift_status], 1
                cmp byte [capslock_status], 1
                je .shift_caps_pressed
		jmp .exit

	.caps_pressed:
		cmp byte [capslock_status], 1
		je .caps_unpressed
		cmp byte [shift_status], 1
		je .shift_caps_pressed
		mov byte [capslock_status], 1
		jmp .exit
	
	.caps_unpressed:
		mov byte [capslock_status], 0
		mov byte [capslock_shift_status], 0
		jmp .exit

	.shift_caps_pressed:
		mov byte [capslock_shift_status], 1
		mov byte [capslock_status], 1
		mov byte [shift_status], 1
		jmp .exit

	.choose_backspace:
                push ax
                xor ax, ax
                add al, [std_backspace]
		add al, [shell_backspace]
                cmp al, 1
                jle .backspace_skip
                jmp .panic
                .backspace_skip:
                pop ax
                cmp byte [std_backspace], 1
                je .backspace
                cmp byte [shell_backspace], 1
                je .backspace_1
                jmp .exit

	.backspace_1:
		push ax
		push es
		mov ax, 0xb800
		mov es, ax
		mov ax, [es:di-2]
		cmp al, 0xff
		je .pre_exit
		pop es
		pop ax
		sub di, 2
		putChar 0x00, 0x07, di
		sub di, 2
		setCursorPos
		jmp .exit

	.pre_exit:
		pop es
		pop ax
		jmp .exit

	.backspace:
		cmp [limit_di], di
		je .backspace_prevrow
		sub di, 2
		putChar 0x00, 0x07, di
		sub di, 2
		setCursorPos
		jmp .exit

	.backspace_prevrow:
		sub word [limit_di], 160
		sub di, 160
		push ax
		push es
                mov ax, 0xb800
                mov es, ax
		jmp .backspace_check

	.backspace_check:
		mov ax, [es:di]
		test al, al
		jnz .backspace_correct
		setCursorPos
		pop es
		pop ax
		jmp .exit

	.backspace_correct:
		add di, 2
		jmp .backspace_check
		
	.choose_enter:
		push ax
		xor ax, ax
		add al, [std_enter]
		add al, [shell_enter]
		cmp al, 1
		jle .enter_skip
		jmp .panic
		.enter_skip:
		pop ax
		cmp byte [std_enter], 1
		je .enter
		cmp byte [shell_enter], 1
		je .enter_1
		jmp .exit

	.enter_1:
		eoiMaster
		scrollDown
                mov di, [limit_di]
		mov byte [process_num], 2
		call start_process
		cmp byte [shell_parser_err], 1
		je .enter_skip_1
		cmp byte [shell_parser_ignore], 1
                je .enter_skip_2
		call start_process
		.enter_skip_1:
		mov byte [shell_parser_err], 0
		scrollDown
		.enter_skip_2:
		mov byte [shell_parser_ignore], 0
		mov byte [process_num], 1
		mov di, [limit_di]
                print shell_cmdln, 0x0f, di
                putChar 0xff, 0x07, di
                setCursorPos
		mov word [scroll_counter], 0
		pop bx
		pop ax
		iret

	.enter:
		push si
		push ax
		push ds
		push es
		push cx
		push dx
		pushf
		add word [limit_di], 160
		mov cx, 4000
		sub cx, [limit_di]
		shr cx, 1
		mov dx, [limit_di]
		mov di, 3998
		mov si, 3998-160
		mov ax, 0xb800
		mov es, ax
		mov ds, ax
		std
		rep movsw
		cld
		mov di, dx
		mov cx, 80
	.fill_row_null:
		putChar	0x00, 0x07, di
		loop .fill_row_null
		mov di, dx
		setCursorPos
		popf
		pop dx
		pop cx
		pop es
		pop ds
		pop ax
		pop si
		jmp .exit

	.choose_up:
                push ax
                xor ax, ax
                add al, [std_up]
                cmp al, 1
                jle .up_skip
                jmp .panic
                .up_skip:
                pop ax
                cmp byte [std_up], 1
                je .up
		jmp .exit

	.choose_left:
                push ax
                xor ax, ax
                add al, [std_left]
		add al, [shell_left]
                cmp al, 1
                jle .left_skip
                jmp .panic
                .left_skip:
                pop ax
                cmp byte [std_left], 1
                je .left
		cmp byte [shell_left], 1
                je .left_1
		jmp .exit
	
	.left_1:
		push ax
		push es
		mov ax, 0xb800
		mov es, ax
		mov ax, [es:di-2]
		cmp al, 0xff
		je .pre_exit
		pop es
		pop ax
		sub di, 2
		setCursorPos
		jmp .exit

        .choose_down:
                push ax
                xor ax, ax
                add al, [std_down]
                cmp al, 1
                jle .down_skip
                jmp .panic
                .down_skip:
                pop ax
                cmp byte [std_down], 1
                je .down
		jmp .exit

        .choose_right:	
                push ax
                xor ax, ax
                add al, [std_right]
		add al, [shell_right]
                cmp al, 1
                jle .right_skip
                jmp .panic
                .right_skip:
                pop ax
                cmp byte [std_right], 1
                je .right
		cmp byte [shell_right], 1
                je .right_1
		jmp .exit

	.right_1:
		push ax
		push es
		mov ax, 0xb800
		mov es, ax
		mov ax, [es:di]
		cmp al, 0x00
		je .pre_exit
		pop es
		pop ax
		add di, 2
		setCursorPos
		jmp .exit

; ===== UP =====

	.up:
		sub word [limit_di], 160
		sub di, 160
		push ax
		push es
		mov ax, 0xb800
		mov es, ax
		jmp .down_up_check

; ===== LEFT =====

	.left:
		cmp [limit_di], di
		je .left_prevrow
		sub di, 2
		setCursorPos
		jmp .exit

	.left_prevrow:
		sub word [limit_di], 160
		sub di, 160
		push ax
		push es
		mov ax, 0xb800
		mov es, ax
		jmp .left_check
	
	.left_check:
		mov ax, [es:di]
		test al, al
		jnz .left_correct
		setCursorPos
		pop es
		pop ax
		jmp .exit
	
	.left_correct:
		add di, 2
		jmp .left_check

; ===== DOWN =====
	
        .down:
		add word [limit_di], 160
		add di, 160
		push ax
		push es
		mov ax, 0xb800
		mov es, ax
		jmp .down_up_check
	
	.down_up_check:
		mov ax, [es:di]
		test al, al
		jz .down_up_correct
		cmp byte [null_flag], 1
		je .down_up_inc
	.down_up_skip_1:
                mov byte [null_flag], 0
		setCursorPos
		pop es
		pop ax
		jmp .exit

	.down_up_inc:
		mov byte [null_flag], 0
		add di, 2
		jmp .down_up_skip_1

	.down_up_correct:
		cmp [limit_di], di
		je .down_up_skip_1
                sub di, 2
		mov byte [null_flag], 1
		jmp .down_up_check
		
; ===== RIGHT =====

        .right:
		push ax
		push es
		mov ax, 0xb800
		mov es, ax
		jmp .right_check

                setCursorPos
                jmp .exit

	.right_check:
		mov ax, [es:di]
		test al, al
		jz .right_correct
		add di, 2
		jmp .right_exit	

	.right_correct:
		add word [limit_di], 160
		mov di, [limit_di]

	.right_check_2:
		mov ax, [es:di]
		test al, al
		jnz .right_correct_2

	.right_exit:
		setCursorPos
		pop es
		pop ax
		jmp .exit

	.right_correct_2:
		add di, 2
		jmp .right_check_2
		
		

.skip_1:
	xlat
	test al, al
	jz .exit
	putChar al, 0x07, di	; Yeah, print characters :3
	cmp di, 4000
	je .scrolldown
.skip_3:
	setCursorPos
	jmp .exit

.scrolldown:
	scrollDown
        sub di, 160
        add word [scroll_counter], 160
	jmp .skip_3

.exit:
	pop bx
	pop ax			; backup Registers
	eoiMaster		; EOI
	iret			; And return

.just_exit:
	eoiMaster
	iret
	
.panic:
	panic kbd_error_msg

kbd_error_msg db "keyboard driver returns error.", 0
shift_status db 0
capslock_status db 0
capslock_shift_status db 0
limit_di dw 0
null_flag db 0
scroll_counter dw 0

std_table:
	db 0, 0, "1234567890-=", 0
	db 0, "qwertyuiop[]", 0, 0
	db "asdfghjkl;'`", 0, '\'
	db "zxcvbnm,./", 0, 0, 0, ' ', 0
	times 25 db 0

shift_table:
	db 0, 0, "!@#$%^&*()_+", 0
        db 0, "QWERTYUIOP{}", 0, 0
        db "ASDFGHJKL:", '"', "~", 0, '|'
        db "ZXCVBNM<>?", 0, 0, 0, ' ', 0
        times 25 db 0

caps_table:
	db 0, 0, "1234567890-=", 0
        db 0, "QWERTYUIOP[]", 0, 0
        db "ASDFGHJKL;'`", 0, '\'
        db "ZXCVNM,./", 0, 0, 0, ' ', 0
        times 25 db 0

caps_shift_table:
	db 0, 0, "!@#$%^&*()_+", 0
        db 0, "qwertyuiop{}", 0, 0
        db "asdfghjkl:", '"', "~", 0, '|'
        db "zxcvbnm<>?", 0, 0, 0, ' ', 0
        times 25 db 0

; 4 char tables. looks like a bloat :\
; no, i did mistake, all of this code are bloat
