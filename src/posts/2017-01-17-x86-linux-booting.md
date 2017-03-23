<!--
{
  "title": "x86 Linux Booting",
  "date": "2017-01-17T03:38:45.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

- Goal: "power on" to "pid 1" on my pc
- Sub goals:
  - kernel image build system
  - bootstrap
  - how does cpu reach start_kernel ?
  - arch/x86/boot, arch/x86/boot/compressed
  - setup_64, 
  - initrd, initramfs
  - real mode to protected mode
  - swapper process

- vmlinuz (a.k.a. bzImage) building
  - ? you can look at ubuntu kernel deb source
  - main makefiles
  - general vmlinux creation flow between root, arch/x86/boot, and arch/x86/boot/compressed
  - understand host programs (mkpiggy, tools/build) and some linker script (vmlinux.lds),

```
## Makefile ##
all: vmlinux
include arch/$(SRCARCH)/Makefile

## arch/x86/Makefile ##
all: bzImage
	$(Q)$(MAKE) $(build)=$(boot) $(KBUILD_IMAGE) # chain kbuild into arch/x86/boot/
	...

## arch/x86/boot/Makefile ##
cmd_image = $(obj)/tools/build $(obj)/setup.bin $(obj)/vmlinux.bin $(obj)/zoffset.h $@
$(obj)/bzImage: $(obj)/setup.bin $(obj)/vmlinux.bin $(obj)/tools/build FORCE
	$(call if_changed,image)
	@echo 'Kernel: $@ is ready' ' (#'`cat .version`')'

$(obj)/vmlinux.bin: $(obj)/compressed/vmlinux FORCE
	$(call if_changed,objcopy)

$(obj)/compressed/vmlinux:
	$(Q)$(MAKE) $(build)=$(obj)/compressed $@ # chain kbuild into arch/x86/boot/compressed/

# Basic flow of this Makefile
# - object files =(setup.ld)=> setup.elf ==(objcopy)==> setup.bin
# - vmlinux (under compressed) ==(objcopy)==> vmlinux.bin (under boot) ==(build setup.bin vmlinux.bin zoffset.h)==> bzImage

## arch/x86/boot/compressed/Makefile ##
vmlinux-objs-y:= piggy.o, ...

$(obj)/vmlinux: $(vmlinux-objs-y) FORCE
	$(call if_changed,check_data_rel)
	$(call if_changed,ld)

$(obj)/vmlinux.bin: vmlinux FORCE
	$(call if_changed,objcopy)

$(obj)/vmlinux.bin.gz: $(vmlinux.bin.all-y) FORCE
	$(call if_changed,gzip)

suffix-$(CONFIG_KERNEL_GZIP)	:= gz

$(obj)/piggy.S: $(obj)/vmlinux.bin.$(suffix-y) $(obj)/mkpiggy FORCE
	$(call if_changed,mkpiggy)

# Basic flow of this Makefile
# - vmlinux (under root) ==(objcopy)==> vmlinux.bin (under compressed) ==(gzip)==> vmlinux.bin.gz ==(mkpiggy)==> piggy.S ==(as .incbin)==> piggy.o
# - *.o ==(vmlinux.lds)==> vmlinux (under compressed)
```

- System setup
  - ? Documentation/x86/boot.txt
  - firmware (BIOS) => refind (\EFI\refind\refind_x64.efi) => ubuntu efi (\EFI\ubuntu\grubx64.efi) => grub2 (/boot/grub/grub.cfg) => vmlinuz
  - setup.bin
    - main => go_to_protected_mode => protected_mode_jump => ???
  - startup_64 (arch/x86/boot/compressed/head_64.S)
  - startup_64 (arch/x86/kernel/head_64.S)
  - arch/x86/kernel/head_64.S
    - start_cpu0 => start_cpu
      - movq	initial_code(%rip), %rax
      - GLOBAL(initial_code)
      - .quad	x86_64_start_kernel
  - arch/x86/boot/compressed/head_64.S
    - startup32
  - ??? => x86_64_start_kernel => x86_64_start_reservations => start_kernel

- EFI
  - what firmware (nvram) supposed to do
  - how to configure those things from linux user space 
  - how to write efi applications (is that elf?)
  - `efibootmgr -v`

- initrd.img
  - check content by `gzip -S .gz -cd /boot/initrd.img-$(uname -r) | cpio -t`
  - some "initramfs-tools" builds it, which is triggered as deb hook for kernel package installation.
  - reference: https://wiki.ubuntu.com/CustomizeLiveInitrd
  - Kconfig: BLK_DEV_INITRD (BLK_DEV_RAM)
  - boot steps:
      - ... => prepare_namespace => load_initrd
      - so this looks like after "rootf" and before "ROOT_DEV".
  - ? how could sys_open("/initrd.image") before mounting real root file system ?
      - is /initrd.image accessible from "rootfs" ?
  - /linuxrc under will be run as work queue, but synchronously
      - ? where does that executable come from ?
  - grub does stuff ?