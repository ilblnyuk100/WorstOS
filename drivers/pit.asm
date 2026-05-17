[bits 16]

pit:
	push si
	mov byte [int_from_pit], 1
	inc dword [sys_counter]
	mov si, sys_config_buffer
	inc si
	cmp byte [ds:si], 1
	je .skip_1
	cmp dword [screensvr_target], 0
	jne .skip
	push ecx
	mov ecx, [screensvr_target]
	mov ecx, [sys_counter]
	add ecx, 1000
	mov [screensvr_target], ecx
	pop ecx
.skip:
	push ecx
	mov ecx, [screensvr_target]
	cmp [sys_counter], ecx
	jge .screensvr_counter_inc
	pop ecx
.skip_1:
	pop si
	eoiMaster
	iret

.screensvr_counter_inc:
	pop ecx
	inc word [screensvr_counter]
	mov dword [screensvr_target], 0
	cmp word [screensvr_counter], 120
	je .screensvr_enable
	pop si
	eoiMaster
	iret

.screensvr_enable:
	mov byte [screensvr_status], 1
	pop si
	eoiMaster
	iret

screensvr_target dd 0
int_from_pit db 0
screensvr_counter dw 0
sys_counter dd 0
screensvr_status db 0
