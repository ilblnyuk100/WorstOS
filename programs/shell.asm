[bits 16]

shell:
	.setup_environment:
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
		

	.start:
		mov word [limit_di], 3840
		mov di, [limit_di]
		print shell_cmdln, 0x0f, di
		putChar 0xff, 0x07, di
		setCursorPos
		jmp .halt_loop
            		
	.halt_loop:
		hlt
		call screensvr
		jmp .halt_loop

shell_cmdln db "WORST/OS>", 0
