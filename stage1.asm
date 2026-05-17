[org 0x7c00]
[bits 16]

%include "constants.inc"
%include "include/worstlib.inc"

_start:
	cli
	xor ax, ax
	mov es, ax
	mov ds, ax

	print stage1_msg_1, 0x07, 0
	initStack 0, 0x7c00
	print stage1_success_msg, 0x08, di

	print stage1_msg_2, 0x07, 160
	sendToPort 0x1f6, 0b11100000
	sendToPort 0x1f2, OS_SIZE_IN_SECTORS
	sendToPort 0x1f3, 1
	sendToPort 0x1f4, 0
	sendToPort 0x1f5, 0

	waitDRDY
	sendToPort 0x1f7, 0x20
	print stage1_success_msg, 0x08, di

	print stage1_msg_4, 0x07, 320
	push di
	mov di, 0x0000
	mov cx, OS_SIZE_IN_SECTORS
	.copy_to_ram:
		waitDRQ
		copySectorToRAM 0x1000, di
		loop .copy_to_ram
	pop di
	print stage1_success_msg, 0x08, di

	print stage1_end_msg, 0x07, 480	
	jmp 0x1000:0x0000

stage1_msg_1 db "Initializing stack...", 0
stage1_msg_2 db "Setup disk...", 0
stage1_msg_4 db "Copying Data to RAM...", 0

stage1_success_msg db " OK", 0
stage1_end_msg db "Starting OS...", 0

markBootable
