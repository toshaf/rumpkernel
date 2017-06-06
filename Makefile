.PHONY: all
all: native iso

.PHONY: native
native: bin/native

.PHONY: iso
iso: bin/unikernel.iso

.PHONY: clean
clean:
	rm -rf .build
	rm -rf bin

bin/native: unikernel.c
	mkdir -p bin
	gcc -o bin/native unikernel.c

GCC=scripts/rmp x86_64-rumprun-netbsd-gcc
BAKE=scripts/rmp rumprun-bake

.build/unikernel.bin: unikernel.c
	mkdir -p bin
	mkdir -p .build
	$(GCC) -o .build/unikernel.raw unikernel.c
	$(BAKE) hw_generic .build/unikernel.bin .build/unikernel.raw

bin/unikernel.iso: .build/unikernel.bin grub.cfg
	mkdir -p .build/iso/boot/grub
	cp .build/unikernel.bin .build/iso/boot
	cp grub.cfg .build/iso/boot/grub
	grub-mkrescue -o bin/unikernel.iso .build/iso

.PHONY: docker
docker:
	docker build -t rump container/

.PHONY: run
run: bin/unikernel.iso
	qemu-system-x86_64 -cdrom bin/unikernel.iso

.PHONY: rumprun
rumprun: .build/unikernel.bin
	scripts/rmp rumprun qemu -i -I if,vioif,'-net tap,script=no,ifname=tap0' -W if,inet,static,10.0.120.101/24 -M 128 .build/unikernel.bin

bin/hdd.img:
	mkdir -p .build
	dd if=/dev/zero of=.build/hdd.img bs=4k count=60000
	mkfs.ext3 .build/hdd.img
