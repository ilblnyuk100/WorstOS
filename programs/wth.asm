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
	putChar '-', 0x0f, 3840
	print wth_bootsplash, 0x07, di
	scrollDown
	print wth_bootsplash_help, 0x08, 3840
	scrollDown
	putChar '-', 0x0f, 3840
	print wth_screensaver, 0x07, di
	scrollDown
	print wth_screensaver_help, 0x08, 3840
	scrollDown
	scrollDown
	print wth_sysdump, 0x07, 3840
	scrollDown
	print wth_website, 0x09, 3840
	scrollDown
	print wth_github, 0x09, 3840
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
wth_bootsplash db " bootsplash - enable or disable splash screen on boot (default enable)", 0
wth_bootsplash_help db "  Usage: bootsplash [enable/disable]", 0
wth_screensaver db " screensaver - enable or disable screen saver (default enable)", 0
wth_screensaver_help db "  Usage: screensaver [enable/disable]", 0
wth_sysdump db "To open/close system dump, press 'Super+UP/DOWN'", 0
wth_website db "My website: 'https://worst-os.ru/'", 0
wth_github db "My github repository: 'https://github.com/ilblnyuk100/WorstOS/'", 0
