SRC=src

AS = nasm
ASFLAGS = -f elf32

LD=ld
LDFLAGS = -T $(SRC)/link.ld -melf_i386

CC = gcc
CFLAGS = -m32 -nostdlib -nostdinc -fno-builtin -fno-stack-protector \
		 -nostartfiles -nodefaultlibs -c \
		 -Wall -Wextra \
		 -I./include -I./$(SRC) -std=c11 -pedantic # -Werror

OBJECTS = $(SRC)/boot.o $(SRC)/kmain.o $(SRC)/io.o $(SRC)/fb.o

all: kernel.elf

%.o: %.c
	$(CC) $(CFLAGS)  $< -o $@

%.o: %.s
	$(AS) $(ASFLAGS) $< -o $@

kernel.elf: $(OBJECTS)
	$(LD) $(LDFLAGS) $(OBJECTS) -o $(SRC)/kernel.elf

iso: kernel.elf
	cp $(SRC)/kernel.elf iso/kernel.elf
	genisoimage -R                              \
				-b boot/grub/stage2_eltorito    \
				-no-emul-boot                   \
				-boot-load-size 4               \
				-A os                           \
				-input-charset utf8             \
				-quiet                          \
				-boot-info-table                \
				-o tantra.iso                   \
				iso

run: iso
	bochs -f utils/bochsrc.txt -q

run-qemu: clean iso
	qemu-system-i386 -cdrom tantra.iso

clean:
	rm -rf $(SRC)/*.o $(SRC)/kernel.elf iso/kernel.elf tantra.iso