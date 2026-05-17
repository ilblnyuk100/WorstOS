reboot:
	getFromPort al, 0x92
	or al, 0b00000001
	sendToPort 0x92, al
