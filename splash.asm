[bits 16]

splash_config_disable:
        push es
        push di
        push ax
        mov di, sys_config_buffer
        mov ax, ds
        mov es, ax
        mov byte [es:di], 1
        mov ax, 30
        loadToDisk al, ah, 0, 0, 1, ds, sys_config_buffer
        pop ax
        pop di
        pop es
	print splash_disable_msg, 0x0c, di
        ret

splash_config_enable:
        push es
        push di
        push ax
        mov di, sys_config_buffer
        mov ax, ds
        mov es, ax
        mov byte [es:di], 0
        mov ax, 30
        loadToDisk al, ah, 0, 0, 1, ds, sys_config_buffer
        pop ax
        pop di
        pop es
	print splash_enable_msg, 0x0a, di
        ret

splash_enable_msg db "Splash Screen ENABLED", 0
splash_disable_msg db "Splash Screen DISABLED", 0
