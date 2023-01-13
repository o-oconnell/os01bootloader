.PHONY: bootloader


bootloader: bootloader.asm kernel.asm
	nasm -f bin bootloader.asm -o bootloader
	nasm -f bin kernel.asm -o kernel
	dd if=/dev/zero of=disk.img bs=512 count=2880
	dd conv=notrunc if=bootloader of=disk.img bs=512 count=1 seek=0
	dd if=kernel of=disk.img bs=512 count=1 seek=1

qemu:
	qemu-system-i386 -machine q35 -fda disk.img -gdb tcp::26000 -S
