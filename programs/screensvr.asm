[bits 16]

screensvr:
	cmp byte [screensvr_status], 0
	jne .skip
	ret
	.skip:
        mov word [screensvr_counter], 0
	push ds
	push es
	push di
	push si
	push cx
	push ax

	push ds

	mov di, screensvr_buffer
	mov ax, ds
	mov es, ax
	mov ax, 0xb800
	mov ds, ax
	mov si, 0
	mov cx, 2000
	cld
	rep movsw

	pop ds

	fillScreen 0x00, 0x07
	print screensvr_msg, 0x08, 1984
	setCursorPos
	sleep 1000
	print screensvr_msg, 0x07, 1984
	sleep 1000
	print screensvr_msg, 0x0f, 1984

	.halt:
		mov byte [int_from_pit], 0
		mov word [screensvr_counter], 0
		hlt
		cmp byte [int_from_pit], 1
		je .halt

	mov ax, 0xb800
	mov es, ax
	mov si, screensvr_buffer
	mov di, 0
	mov cx, 2000
	cld
	rep movsw

	pop ax
	pop cx
	pop si
	pop di
	setCursorPos
	pop es
	pop ds
	mov byte [screensvr_status], 0
	ret	

screensvr_msg db "Where Are You? :3", 0
screensvr_buffer times 2000 dw 0
