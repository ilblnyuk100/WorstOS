[bits 16]

wth:
	print wth_greeting, 0x0f, 3840
	print sys_version, 0x08, di
	scrollDown
	print wth_msg, 0x07, 3840
	scrollDown
	print wth_msg_2, 0x07, 3840
        scrollDown
        print wth_msg_3, 0x07, 3840
        scrollDown
        print wth_msg_4, 0x07, 3840 
	scrollDown
	scrollDown
	putChar '-', 0x0f, 3840
	print wth_test1, 0x07, di
        scrollDown
        putChar '-', 0x0f, 3840
        print wth_test2, 0x07, di
        scrollDown
        putChar '-', 0x0f, 3840
        print wth_clearscr, 0x07, di
        scrollDown
        putChar '-', 0x0f, 3840
        print wth_reboot, 0x07, di
	scrollDown
	scrollDown
	print wth_bye, 0x0f, 3840
	ret
	
	

wth_greeting db "Welcome to Worst/OS!! ", 0
wth_msg db "This OS has been created by GodHex (Balanyuk Ilya) just for fun", 0
wth_msg_2 db "Honestly, I didn't except that I can make something like this,", 0
wth_msg_3 db "but literaly after 5 days of work at my OS I already wrote working prototype.", 0 
wth_msg_4 db "It's amazing! isn't it? ", 0x02, 0
wth_msg_5 db "Ok, let's walk around my programs for cmdline:", 0
wth_test1 db " test1 - just a command for debugging how my parser works. and it's works fine", 0
wth_test2 db " test2 - another debug program", 0
wth_clearscr db " clearscr - this command clears screen from bloat, it's useful", 0
wth_reboot db " reboot - just reboots PC, faster than reboot by pressing a power button", 0
wth_bye db "that's it for a while", 0
