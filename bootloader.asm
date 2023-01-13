start:	
	cli
	mov ax, 0x50
	mov es, ax 		
	xor bx, bx		; es:bx contains the memory address at which the sector(s) will be loaded by this interrupt routine. The es:bx notation means that the value in es is left shifted by 4 bits before adding to bx. Therefore es:bx = 0x500.
	mov cl, 2		; first sector to read	
	mov al, 1		; number of sectors to read starting from the sector number in cl
	mov ch, 0		; lower eight bits of the cylinder number
	mov dh, 0 		; head number 
	mov dl, 0		; drive number 
	mov ah, 0x02		; used to indicate which routine we want
	int 0x13		; interrupt 13 with ah = 02h
	mov bx, 0x0500 		; the memory address of the kernel loaded into memory
	jmp bx			; jump to the kernel code
	

times 510-($-$$) db 0		; $ is an assembler directive referring to the current position (in bytes) within this file at the beginning of this line. $$ refers to the beginning of the current section within the file. This ensures that our binary is 512 bytes in total, and trailing bytes up to the boot signature are zeros.
dw 0xAA55					; This is the boot signature. It is a magic number required by the BIOS to be in the bootloader program. If we do not include it, we'll get a "not a bootable disk" error.
