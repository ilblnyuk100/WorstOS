; WorstOS Library (made it for comfortable work)
; P.S.: (And bloat :\ )

; === PORTS ==============================================================================================================================================================================================================

%macro sendToPort 2	; 1st arg - Port; 2nd arg - Value
	push dx
	push ax
	mov dx, %1
	mov al, %2
	out dx, al
	pop ax
	pop dx
%endmacro

%macro getFromPort 2	; 1st arg - Register; 2nd arg - Port
	push dx
	mov dx, %2
	in %1, dx
	pop dx
%endmacro

; === GRAPHICS ===========================================================================================================================================================================================================

%macro printImage 2 ; 1st arg - segment; 2nd arg - image
	push cx
	push es
	push ax
	push di
	push si
	push ds
	mov si, %2
	mov ax, %1
	mov ds, ax
	xor di, di
	mov ax, 0xa000
	mov es, ax
	mov cx, 32000
	rep movsw
	pop ds
	pop si
	pop di
	pop ax
	pop es
	pop cx
%endmacro

%macro scrollDown 0
	push es
	push ds
	push di
	push si
	push ax
	push cx
	mov ax, 0xb800
	mov es, ax
	mov ds, ax
	mov si, 320
	mov di, 160
	mov cx, 1920
	rep movsw
	mov cx, 80
	mov di, 3840
	%%loop:
		mov word [es:di], 0x0700
		add di, 2
		loop %%loop
	pop cx
	pop ax
	pop si
	pop di
	pop ds
	pop es
%endmacro

%macro fillScreen 2	; 1st arg - Character; 2nd arg - Attribute
	push cx
	push di
	mov cx, 80*24
	mov di, 160
	%%fill:
		putChar %1, %2, di
		loop %%fill
	pop di
	pop cx
%endmacro

%macro fillAllScreen 2     ; 1st arg - Character; 2nd arg - Attribute
        push cx
        push di
        mov cx, 80*25
        xor di, di
        %%fill:
                putChar %1, %2, di
                loop %%fill
        pop di
        pop cx
%endmacro

%macro setCursorPos 0	; di divided by two will be used as the cursor position
	push bx
	push dx
	push ax
	mov bx, di
	shr bx, 1
	mov dx, 0x3d4
	mov al, 0x0e
	out dx, al
	mov al, bh
	inc dx
	out dx, al
	dec dx
	mov al, 0x0f
	out dx, al
	inc dx
	mov al, bl
	out dx, al
	pop ax
	pop dx
	pop bx
%endmacro

%macro print 3		; 1st arg - Text; 2nd arg - Attribute (hex); 3rd arg - Offset
	push si
	push ax
	push es
	mov ax, 0xb800
	mov es, ax
	mov si, %1
	mov ah, %2
	mov di, %3
	%%loop:
		lodsb
		test al, al
		jz %%end
		mov [es:di], ax
		add di, 2
		jmp %%loop
	%%end:
		pop es
		pop ax
		pop si
%endmacro

%macro putChar 3	; 1st arg - Character; 2nd arg - Attribute (hex); 3rd arg - Offset
	push es
	push ax
	mov ax, 0xb800
	mov es, ax
	pop ax
	push ax
	mov al, %1
	mov ah, %2
	mov di, %3
	mov [es:di], ax
	add di, 2
	pop ax
	pop es
%endmacro

; === ATA IDE ============================================================================================================================================================================================================


%macro loadFromDisk 7 ; 1st arg - low sector; 2nd arg - mid sector; 3rd arg - high sector; 4th arg - really high sector (max. 16); 5th arg - how many sectors; 6th arg - to segment in ram; 7th arg - to offset in ram 
	push ax
	mov al, 0b11100000
	or al, %4
	sendToPort 0x1f6, al
	pop ax
	sendToPort 0x1f2, %5
	sendToPort 0x1f3, %1
	sendToPort 0x1f4, %2
	sendToPort 0x1f5, %3

	waitDRDY
	sendToPort 0x1f7, 0x20

	push di
	mov di, %7
	mov cx, %5
	%%copy_to_ram:
		waitDRQ
		copySectorToRAM %6, di
		loop %%copy_to_ram
	pop di
%endmacro

%macro loadToDisk 7 ; 1st arg - low sector; 2nd arg - mid sector; 3rd arg - high sector; 4th arg - really high sector (max. 16); 5th arg - how many sectors; 6th arg - from segment in ram; 7th arg - from offset in ram
        push ax
        mov al, 0b11100000
        or al, %4
        sendToPort 0x1f6, al
        pop ax
        sendToPort 0x1f2, %5
        sendToPort 0x1f3, %1
        sendToPort 0x1f4, %2
        sendToPort 0x1f5, %3

        waitDRDY
        sendToPort 0x1f7, 0x30

        push si
        mov si, %7
        mov cx, %5
        %%copy_from_ram:
                waitDRQ
                copySectorFromRAM %6, si
                loop %%copy_from_ram
        pop si
%endmacro

%macro waitDRDY 0
	push ax
	push dx
	mov dx, 0x1f7
	%%BSY:
		in al, dx
		test al, 0b10000000
		jnz %%BSY
	%%DRDY:
		in al, dx
		test al, 0b01000000
		jz %%DRDY
	pop dx
	pop ax
%endmacro

%macro waitDRQ 0
        push ax
	push dx
	mov dx, 0x1f7
        %%BSY:
                in al, dx
                test al, 0b10000000
                jnz %%BSY
        %%DRQ:
                in al, dx
                test al, 0b00001000
                jz %%DRQ
	pop dx
        pop ax
%endmacro 

%macro	copySectorToRAM 2	; 1st arg - Segment; 2nd arg - Offset
	push ax
	push dx
	push cx
	mov dx, 0x1f0
	mov ax, %1
	mov es, ax
	mov di, %2
	mov cx, 256
	rep insw	; 256 times (0x1f0 -> [es:di]; di+=2)
	pop cx
	pop dx
	pop ax
%endmacro

%macro  copySectorFromRAM 2       ; 1st arg - Segment; 2nd arg - Offset
        push ax
        push dx
        push cx
	push ds
	push si
        mov dx, 0x1f0
        mov ax, %1
        mov ds, ax
        mov si, %2
        mov cx, 256
        rep outsw        ; 256 times (0x1f0 -> [ds:si]; si+=2)
	pop si
	pop ds
        pop cx
        pop dx
        pop ax
%endmacro

; === SND ================================================================================================================================================================================================================

%macro playSound 1	; 1st arg - frequency
	push ax
	push dx
	push cx
	sendToPort 0x43, 0b10110110
	mov ax, 0x34de
	mov dx, 0x0012
	mov cx, %1
	div cx
	sendToPort 0x42, al
	sendToPort 0x42, ah
	getFromPort al, 0x61
	or al, 0b00000011
	sendToPort 0x61, al
	pop cx
	pop dx
	pop ax
%endmacro

%macro stopSound 0
	push ax
        getFromPort al, 0x61
        and al, 0b11111100
        sendToPort 0x61, al
	pop ax
%endmacro

; === MISC ===============================================================================================================================================================================================================

%macro sleep 1		; 1st arg - ms
	push eax
	mov eax, [sys_counter]
	add eax, %1
	%%loop:
		hlt
		cmp [sys_counter], eax
		jl %%loop
	pop eax
%endmacro

%macro eoiMaster 0
	push ax
	mov al, 0x20
	out 0x20, al
	pop ax
%endmacro

%macro eoiSlave 0
        push ax
        mov al, 0x20
        out 0xa0, al
	out 0x20, al
        pop ax
%endmacro

%macro markBootable 0
	times 510-($-$$) db 0
	dw 0xaa55
%endmacro

%macro initStack 2	; 1st arg - Stack Segment; 2nd arg - Stack Pointer
	push ax
	mov ax, %1
	mov ss, ax
	mov sp, %2
	pop ax
%endmacro

%macro panic 1		; 1st arg - message
	cli
	fillScreen 0x00, 0x4f
	print panic_msg, 0x4f, 3684
	print %1, 0x4f, di
	setCursorPos

	push si
        push ax
        push es
	push cx
	push bx
        mov ax, 0xb800
        mov es, ax
        mov si, ascii_panic
        mov di, 1194
	mov cx, 9

	%%loop_1:
		mov bx, 5
	        %%loop_2:
			mov ah, 0x4f
	                lodsb
			cmp al, '#'
			je %%skip_1
			jmp %%skip_2
			%%skip_1:
			mov al, 0x20
			mov ah, 0xff
			%%skip_2:
	                mov [es:di], ax	
	                add di, 2
	                dec bx
			test bx, bx
			jnz %%loop_2
		sub di, 10
		add di, 160
		loop %%loop_1
        %%end:
		pop bx
		pop cx
                pop es
                pop ax
                pop si

	hlt
%endmacro

; === END ================================================================================================================================================================================================================