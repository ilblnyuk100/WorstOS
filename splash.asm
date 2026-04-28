[bits 16]

outimage:
	cli
	printImage 0x2000, 0x0000
	hlt
