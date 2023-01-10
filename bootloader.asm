org 0x7c00
bits 16
start:	jmp boot
welcome: db "oocOS is the best OS!", 0x00

boot:
	cli
	cld
	call clearScreen
	;; welcome  = argument to print
	mov si, welcome 		; we're in 16-bit real mode, use 16-bit regs for addresses
	call print
	nop
	nop
	mov eax, 0x70
	
	hlt

cursorX: db 0x00, 0x00 		; 2 bytes as we're in 16-bit mode, and the registers written to for moving the cursor are dl and dh (16 bit regs)
cursorY: db 0x00, 0x00
	
putchar:
	;; al = character to display, which is what's loaded into by lodsb
	;; number of times to display is in cx

	;; supposedly the color, seems to set text background color. http://www.ctyme.com/intr/rb-0099.htm
	mov bl, 0xab
	mov bh, 0 		;page number
	mov ah, 09h		;interrupt number, indicates write char and attribute at cursor position
	int 0x10

	;; move the cursor one to the right (or however many chars were printed - stored in cx register)
	add [cursorX], cx

	mov dl, [cursorX]
	mov dh, [cursorY]
	call movCursor
	
	ret

movCursor:
	;; dl = row, dh = column
	mov bh, 0		; page number
	mov ah, 2 		; interrupt number modifier

	;; set our cursor X and Y to the row and col that we just moved to
	mov [cursorX], dl
	mov [cursorY], dh
	
	int 10h			; interrupt number that seems to be used for most video
	ret

	;; prints a string. ds:si is a zero-terminated string argument
	;; ds:si = lower 16 bits of ESI, in the data segment
print:
;; local label .loop
	.loop:
	lodsb 			; load a byte from SI into AL
	cmp al, 0x00 		; check if we've reached the null terminator
	jz .done 		; found the null terminator
	mov cx, 0x0001
	call putchar		; handy fact: the AL register is used as the character to print by the interrupt that prints a character on the screen
	jmp .loop
	.done:
	ret

clearScreen:
	;; move the cursor to position 0
	mov dh, 0
	mov dl, 0
	call movCursor

	;; write 80*25 spaces, starting at position 0
	;; putchar (int 10, ah = 09h) only moves the cursor along if you put a number > 1 in cx
	mov bl, 0 		; clear color
	mov al, ' '
	mov cx, 80*25 		; num characters
	call putchar		

	;; move cursor back to position 0
	mov dl, 0
	mov dh, 0
	call movCursor
	ret

times 510-($-$$) db 0				; We have to be 512 bytes. Clear the rest of the bytes with 0
dw 0xAA55					; boot signature! must be here in the program that's loaded from the first sector of the floppy by the BIOS, otherwise we'll get "not a bootable disk" error
