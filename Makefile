COMPILER = ~/opt/cross/bin/i686-elf-gcc
LINKER = ~/opt/cross/bin/i686-elf-ld
ASSEMBLER = nasm
CFLAGS = -m32 -c -ffreestanding -w -fcommon
ASFLAGS = -f elf32
LDFLAGS = -m elf_i386 -T src/boot/link.ld

OBJS = tmp/obj/kasm.o tmp/obj/kc.o tmp/obj/idt.o tmp/obj/ata.o tmp/obj/printf.o tmp/obj/isr.o tmp/obj/kb.o tmp/obj/string.o tmp/obj/system.o tmp/obj/util.o tmp/obj/shell.o tmp/obj/disk.o tmp/obj/fat32.o tmp/obj/rtc.o tmp/obj/testing.o tmp/obj/pmm.o tmp/obj/gdtasm.o tmp/obj/gdt.o tmp/obj/timer.o tmp/obj/schedule.o tmp/obj/pci.o tmp/obj/israsm.o tmp/obj/taskasm.o tmp/obj/task.o tmp/obj/liballoc.o tmp/obj/vga.o tmp/obj/console.o tmp/obj/backupconsole.o tmp/obj/serial.o tmp/obj/elf.o tmp/obj/paging.o tmp/obj/vmm.o
OUTPUT = tmp/boot/kernel.bin

all:$(OBJS)
	mkdir tmp/ -p
	mkdir tmp/boot/ -p
	$(LINKER) $(LDFLAGS) -o $(OUTPUT) $(OBJS)

tmp/obj/kasm.o:src/boot/kernel.asm
	mkdir tmp/obj/ -p
	$(ASSEMBLER) $(ASFLAGS) -o tmp/obj/kasm.o src/boot/kernel.asm

tmp/obj/gdtasm.o:src/cpu/gdt.asm
	mkdir tmp/obj/ -p
	$(ASSEMBLER) $(ASFLAGS) -o tmp/obj/gdtasm.o src/cpu/gdt.asm

tmp/obj/israsm.o:src/cpu/isr.asm
	mkdir tmp/obj/ -p
	$(ASSEMBLER) $(ASFLAGS) -o tmp/obj/israsm.o src/cpu/isr.asm

tmp/obj/taskasm.o:src/multitasking/task.asm
	mkdir tmp/obj/ -p
	$(ASSEMBLER) $(ASFLAGS) -o tmp/obj/taskasm.o src/multitasking/task.asm
	
tmp/obj/vmm.o:src/memory/vmm.c
	$(COMPILER) $(CFLAGS) src/memory/vmm.c -o tmp/obj/vmm.o 
	
tmp/obj/paging.o:src/memory/paging.c
	$(COMPILER) $(CFLAGS) src/memory/paging.c -o tmp/obj/paging.o 
	
tmp/obj/task.o:src/multitasking/task.c
	$(COMPILER) $(CFLAGS) src/multitasking/task.c -o tmp/obj/task.o 
	
tmp/obj/elf.o:src/utilities/elf.c
	$(COMPILER) $(CFLAGS) src/utilities/elf.c -o tmp/obj/elf.o 
	
tmp/obj/serial.o:src/drivers/serial.c
	$(COMPILER) $(CFLAGS) src/drivers/serial.c -o tmp/obj/serial.o 
	
tmp/obj/schedule.o:src/multitasking/schedule.c
	$(COMPILER) $(CFLAGS) src/multitasking/schedule.c -o tmp/obj/schedule.o 
	
tmp/obj/console.o:src/graphical/console.c
	$(COMPILER) $(CFLAGS) src/graphical/console.c -o tmp/obj/console.o 
	
tmp/obj/backupconsole.o:src/graphical/backupconsole.c
	$(COMPILER) $(CFLAGS) src/graphical/backupconsole.c -o tmp/obj/backupconsole.o 
	
tmp/obj/liballoc.o:src/memory/liballoc.c
	$(COMPILER) $(CFLAGS) src/memory/liballoc.c -o tmp/obj/liballoc.o 
	
tmp/obj/timer.o:src/cpu/timer.c
	$(COMPILER) $(CFLAGS) src/cpu/timer.c -o tmp/obj/timer.o 
	
tmp/obj/pci.o:src/drivers/pci.c
	$(COMPILER) $(CFLAGS) src/drivers/pci.c -o tmp/obj/pci.o 
	
tmp/obj/gdt.o:src/cpu/gdt.c
	$(COMPILER) $(CFLAGS) src/cpu/gdt.c -o tmp/obj/gdt.o 
		
tmp/obj/kc.o:src/entry/kernel.c
	$(COMPILER) $(CFLAGS) src/entry/kernel.c -o tmp/obj/kc.o 
		
tmp/obj/idt.o:src/cpu/idt.c
	$(COMPILER) $(CFLAGS) src/cpu/idt.c -o tmp/obj/idt.o 

tmp/obj/kb.o:src/drivers/kb.c
	$(COMPILER) $(CFLAGS) src/drivers/kb.c -o tmp/obj/kb.o

tmp/obj/pmm.o:src/memory/pmm.c
	$(COMPILER) $(CFLAGS) src/memory/pmm.c -o tmp/obj/pmm.o

tmp/obj/isr.o:src/cpu/isr.c
	$(COMPILER) $(CFLAGS) src/cpu/isr.c -o tmp/obj/isr.o

tmp/obj/vga.o:src/drivers/vga.c
	$(COMPILER) $(CFLAGS) src/drivers/vga.c -o tmp/obj/vga.o

tmp/obj/printf.o:src/drivers/printf.c
	$(COMPILER) $(CFLAGS) src/drivers/printf.c -o tmp/obj/printf.o

tmp/obj/ata.o:src/drivers/ata.c
	$(COMPILER) $(CFLAGS) src/drivers/ata.c -o tmp/obj/ata.o

tmp/obj/disk.o:src/drivers/disk.c
	$(COMPILER) $(CFLAGS) src/drivers/disk.c -o tmp/obj/disk.o
	
tmp/obj/fat32.o:src/drivers/fat32.c
	$(COMPILER) $(CFLAGS) src/drivers/fat32.c -o tmp/obj/fat32.o
		
tmp/obj/rtc.o:src/cpu/rtc.c
	$(COMPILER) $(CFLAGS) src/cpu/rtc.c -o tmp/obj/rtc.o

tmp/obj/string.o:src/utilities/shell/string.c
	$(COMPILER) $(CFLAGS) src/utilities/shell/string.c -o tmp/obj/string.o

tmp/obj/system.o:src/cpu/system.c
	$(COMPILER) $(CFLAGS) src/cpu/system.c -o tmp/obj/system.o

tmp/obj/util.o:src/utilities/util.c
	$(COMPILER) $(CFLAGS) src/utilities/util.c -o tmp/obj/util.o

tmp/obj/shell.o:src/utilities/shell/shell.c
	$(COMPILER) $(CFLAGS) src/utilities/shell/shell.c -o tmp/obj/shell.o

tmp/obj/testing.o:src/entry/testing.c
	$(COMPILER) $(CFLAGS) src/entry/testing.c -o tmp/obj/testing.o

iso:all 
	grub-mkrescue -o cavOS.iso tmp/

disk:all
	chmod +x tools/make_disk.sh
	./tools/make_disk.sh

vmware:disk
	qemu-img convert disk.img -O vmdk disk.vmdk

tools:
	chmod +x tools/get_tools.sh
	./tools/get_tools.sh
	
clean:
	rm -f tmp/obj/*.o
	rm -r -f tmp/kernel.bin
	rm -f disk*

qemu:
	qemu-system-x86_64 -d guest_errors -serial stdio -drive file=disk.img,format=raw -m 1g -netdev user,id=mynet0 -net nic,model=ne2k_pci,netdev=mynet0

qemu_iso:
	qemu-system-x86_64 -d guest_errors -serial stdio -drive file=cavOS.iso,format=raw -m 1g -netdev user,id=mynet0 -net nic,model=ne2k_pci,netdev=mynet0

dev:clean disk qemu
