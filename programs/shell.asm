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
		mov byte [shell_up], 1
		mov byte [shell_down], 1
		mov byte [std_base], 1

	.start:
		print topbar, 0x1e, 0
		mov word [limit_di], 3840
		mov di, [limit_di]
		print shell_cmdln, 0x0f, di
		putChar 0xff, 0x07, di
		setCursorPos
		jmp .halt_loop
            		
	.halt_loop:
		hlt
		call sync_time
		call screensvr
		cmp byte [debugscreen_status], 1
		jne .halt_loop
		call debugscreen
		jmp .halt_loop

shell_cmdln db "WorstShell>", 0
debugscreen_status db 0

topbar:
	db "Shell"
	times 33 db 0x20
	db "W/OS"
	times 38 db 0x20
	db 0

topbar_dump:
	db "System Dump"
	times 27 db 0x20
	db "W/OS"
	times 38 db 0x20
	db 0


