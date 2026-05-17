debugscreen:
	mov byte [std_enter], 0
	mov byte [shell_enter], 0
	mov byte [std_backspace], 0
	mov byte [shell_backspace], 0
	mov byte [std_up], 0
	mov byte [std_left], 0
	mov byte [std_down], 0
	mov byte [std_right], 0
	mov byte [shell_left], 0
	mov byte [shell_right], 0
	mov byte [shell_up], 1
	mov byte [shell_down], 1
	mov byte [std_base], 0

	push es
	push ds
	push ax
	push di
	push si

	push ds

	push di
	mov di, 4000
	setCursorPos
	pop di

	mov di, debugscreen_buffer
	mov ax, ds
	mov es, ax
	mov ax, 0xb800
	mov ds, ax
	mov si, 160
	mov cx, 1920
	cld
	rep movsw

	pop ds

	fillScreen 0x00, 0x70
	print topbar_dump, 0x1e, 0

	.halt_loop:
		hlt
		call sync_time
		call screensvr
		call .counter_convert_and_print
		call .bootsplash_status
		call .screensaver_status
		cmp byte [debugscreen_status], 0
		je .exit
		inc byte [debugscreen_counter_update]
		cmp byte [debugscreen_counter_update], 100
		jge .update
		jmp .halt_loop

	.bootsplash_status:
		push si
		print debugscreen_bootsplash_status, 0x70, 320
		mov si, sys_config_buffer
		cmp byte [ds:si], 0
		je .enabled
		cmp byte [ds:si], 1
		je .disabled
		print debugscreen_bad_value, 0x04, di
		pop si
		ret

	.screensaver_status:
		push si
		print debugscreen_screensaver_status, 0x70, 480
		mov si, sys_config_buffer
		inc si
		cmp byte [ds:si], 0
		je .enabled
		cmp byte [ds:si], 1
		je .disabled
		print debugscreen_bad_value, 0x04, di
		pop si
		ret

	.enabled:
		print debugscreen_enabled, 0x2f, di
		pop si
		ret

	.disabled:
		print debugscreen_disabled, 0x4f, di
		pop si
		ret

	.update:
		fillScreen 0x00, 0x70
		mov byte [debugscreen_counter_update], 0
		jmp .halt_loop

	.counter_convert_and_print:
		push eax
		push ecx
		push ebx
		push edx
		push di

		mov eax, [sys_counter]
		mov di, 160
		mov ecx, 10
		xor bx, bx
		print debugscreen_pit_counter_prefix, 0x70, di
	
		.counter_1:
			xor edx, edx
			div ecx
			push edx
			inc bx
			test eax, eax
			jnz .counter_1

		.counter_2:
			pop edx
			dec bx
			add dl, 0x30
			putChar dl, 0x70, di
			test bx, bx
			jnz .counter_2
		
			pop di
			pop edx
			pop ebx
			pop ecx
			pop eax
			ret
		

	.exit:
		mov di, 160
		mov ax, 0xb800
		mov es, ax
		mov si, debugscreen_buffer
		mov cx, 1920
		cld
		rep movsw

		pop si
		print topbar, 0x1e, 0
		pop di
		pop ax
		pop ds
		pop es

		setCursorPos
		mov byte [std_enter], 0
		mov byte [shell_enter], 1
		mov byte [std_backspace], 0
		mov byte [shell_backspace], 1
		mov byte [std_up], 0
		mov byte [std_left], 0
		mov byte [std_down], 0
		mov byte [std_right], 0
		mov byte [shell_left], 1
		mov byte [shell_right], 1
		mov byte [shell_up], 1
		mov byte [shell_down], 1
		mov byte [std_base], 1
		ret

debugscreen_msg db "debugscreen", 0
debugscreen_buffer times 1920 dw 0
counter_length db 0
debugscreen_pit_counter_prefix db "PIT Counter = ", 0
debugscreen_counter_update db 0
debugscreen_bootsplash_status db "Bootsplash Status = ", 0
debugscreen_screensaver_status db "Screen Saver Status = ", 0
debugscreen_bad_value db "bad value!", 0
debugscreen_enabled db "enabled", 0
debugscreen_disabled db "disabled", 0
