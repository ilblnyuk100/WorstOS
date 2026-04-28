[org 0x0000]
[bits 16]

%include "include/worstlib.inc"
%include "drivers/pic.asm"

splash_screen:
	push ax
        mov ax, 0x0013
        int 0x10
        pop ax

	push ax

	mov ax, 28

	playSound 50
	loadFromDisk al, ah, 0, 0, 125, 0xa000, 0x0000
	sleep 996
	stopSound

	
	add ax, 125
	
	loadFromDisk al, ah, 0, 0, 125, 0xa000, 0x0000
	sleep 83
	playSound 1000
        add ax, 125

	loadFromDisk al, ah, 0, 0, 125, 0xa000, 0x0000
        sleep 83
	stopSound

        add ax, 125

	loadFromDisk al, ah, 0, 0, 125, 0xa000, 0x0000
        sleep 83

        add ax, 125

	loadFromDisk al, ah, 0, 0, 125, 0xa000, 0x0000
        sleep 83

        add ax, 125

	loadFromDisk al, ah, 0, 0, 125, 0xa000, 0x0000
        sleep 83

        add ax, 125

	loadFromDisk al, ah, 0, 0, 125, 0xa000, 0x0000
        sleep 913

        add ax, 125

	loadFromDisk al, ah, 0, 0, 125, 0xa000, 0x0000
        sleep 83

        add ax, 125

	loadFromDisk al, ah, 0, 0, 125, 0xa000, 0x0000
        sleep 83

        add ax, 125

	loadFromDisk al, ah, 0, 0, 125, 0xa000, 0x0000
        sleep 830
	
        add ax, 125

	playSound 324	

	loadFromDisk al, ah, 0, 0, 125, 0xa000, 0x0000
        sleep 83

        add ax, 125

	loadFromDisk al, ah, 0, 0, 125, 0xa000, 0x0000
        sleep 83

        add ax, 125

	loadFromDisk al, ah, 0, 0, 125, 0xa000, 0x0000
        sleep 83
	stopSound

        add ax, 125

	loadFromDisk al, ah, 0, 0, 125, 0xa000, 0x0000
        sleep 42
	playSound 288
	sleep 41

        add ax, 125

        loadFromDisk al, ah, 0, 0, 125, 0xa000, 0x0000
        sleep 83

        add ax, 125

        loadFromDisk al, ah, 0, 0, 125, 0xa000, 0x0000
	sleep 208
	stopSound
	sleep 41
	playSound 257
	sleep 498
	stopSound
        sleep 166

        add ax, 125
	
	loadFromDisk al, ah, 0, 0, 125, 0xa000, 0x0000
        sleep 83

        add ax, 125

	loadFromDisk al, ah, 0, 0, 125, 0xa000, 0x0000
        sleep 83

        add ax, 125

	loadFromDisk al, ah, 0, 0, 125, 0xa000, 0x0000
        sleep 83
	

	mov ax, 0x0003
	int 0x10
	pop ax

	


init:
	fillScreen 0x00, 0x07
	print sys_greeting, 0x0e, 3704
	mov di, 3840
	setCursorPos

start_process:
	cmp byte [process_num], 0
	je no_process
	cmp byte [process_num], 1
	je shell
	cmp byte [process_num], 2
	je shell_parser
	cmp byte [process_num], 3
	je test1
	cmp byte [process_num], 4
        je test2
	cmp byte [process_num], 5
	je clearscr
	cmp byte [process_num], 6
	je reboot
	cmp byte [process_num], 7
	je space_skipper
	cmp byte [process_num], 8
	je wth
	jmp .panic

	.panic:
		panic process_error_msg

no_process:
	hlt
	jmp no_process

%include "drivers/keyboard.asm"
%include "drivers/pit.asm"

%include "splash.asm"

%include "programs/testutils.asm"
%include "programs/parser.asm"
%include "programs/shell.asm"
%include "programs/clearscr.asm"
%include "programs/reboot.asm"
%include "programs/space_skipper.asm"
%include "programs/wth.asm"
%include "programs/screensvr.asm"

process_num db 1	; Default 1 (shell). List of processes in "documentation/processes.txt"

process_error_msg db "unknown process.", 0

shell_just_started db 1

std_enter db 1
shell_enter db 0
std_backspace db 1
shell_backspace db 0
std_up db 1
std_left db 1
std_down db 1
std_right db 1
shell_left db 0
shell_right db 0

sys_version db "v0.1.0", 0
sys_greeting db "Welcome to Worst/OS! Type 'wth' to see more informarion", 0

panic_msg db "PANIC: ", 0

ascii_panic:
	db " ### "
	db "#####"
	db "#####"
	db "#####"
	db " ### "
	db " ### "
	db "     "
	db " ### "
	db " ### "



times ((($-$$)+511)/512)*512-($-$$) db 0

splashframes:
	incbin "bootsplash/splash_1.bin"
        incbin "bootsplash/splash_2.bin"
        incbin "bootsplash/splash_3.bin"
        incbin "bootsplash/splash_4.bin"
        incbin "bootsplash/splash_5.bin"
        incbin "bootsplash/splash_6.bin"
        incbin "bootsplash/splash_7.bin"
        incbin "bootsplash/splash_8.bin"
        incbin "bootsplash/splash_9.bin"
        incbin "bootsplash/splash_10.bin"
        incbin "bootsplash/splash_11.bin"
        incbin "bootsplash/splash_12.bin"
        incbin "bootsplash/splash_13.bin"
        incbin "bootsplash/splash_14.bin"
        incbin "bootsplash/splash_15.bin"
        incbin "bootsplash/splash_16.bin"
        incbin "bootsplash/splash_17.bin"
        incbin "bootsplash/splash_18.bin"
        incbin "bootsplash/splash_19.bin"

times ((($-$$)+511)/512)*512-($-$$) db 0
