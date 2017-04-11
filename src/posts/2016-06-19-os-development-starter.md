<!--
{
  "title": "OS Development Starter",
  "date": "2016-06-19T01:12:43.000Z",
  "category": "",
  "tags": [
    "starter",
    "os"
  ],
  "draft": false
}
-->

There's not so much reason. I just wanted to know about what Operating System does. Fortunately, I found a couple of good entry-level articles to create DIY OS.
I made a interpreter or compiler (compiler was for RISC machine) before, but I haven't learnt much about the part of low layer technology where software has to interact with chip resource (CPU or other things).

Here is my source code: https://github.com/hi-ogawa/bare-bones-os, I managed to make my kernel responding keyboard input, like this:

<img src="http://wp.hiogawa.net/wp-content/uploads/2016/06/os_demo-1.gif" alt="os_demo" width="580" height="339" class="alignnone size-large wp-image-827" />

In this post, I don't explain things as always. I'll put a bunch of reference enough to follow my work road below:

## Work Road

- Follow [OSDev Wiki: Bare Bones](http://wiki.osdev.org/Bare_Bones) GOAL: show "hard-coded" text on screen 
  - prepare build environment as [Vagrant](https://atlas.hashicorp.com/hiogawa/boxes/os_dev/) and [Docker](https://hub.docker.com/r/hiogawa/i686-elf/)
  - copy and paste code from the tutorial
  - understand original code:
       - learn normal C code execution model on Unix
            - _Assembler_, _Linker_, _Loader_, _ELF format_, etc
       - learn _Assembly Language_, _Linker script_
       - learn kernel program specific problems:
            - _Booting (GRUB multiboot)_, IO (_VGA TextUI_)
  - refactor original code (remove unnecessary codes)
- Follow [Bran's Kernel Development](http://www.osdever.net/bkerndev/Docs/title.htm) GOAL: show "typing" text on screen interacting with keyboard
  - translate _NASM_ syntax into _GAS_ syntax (the article was using _NASM_)
  - learn exception/interrupt handling (_GDT_, _IDT_, _IRQ_, _ISR_)
  - find corresponding reference in OSDev Wiki for each specific thing
  - move/rename file or function as I feel comfortable

## References

- OSDev Wiki: http://wiki.osdev.org
- Bran's Kernel Development: http://www.osdever.net/bkerndev/Docs/title.htm
- X86 Assembly
  - directives: https://docs.oracle.com/cd/E26502_01/html/E28388/eoiyg.html
  - wikibook: https://en.wikibooks.org/wiki/X86_Assembly
  - instruction set: http://www.felixcloutier.com/x86/
  - control registers (cr ...): 
      - https://en.wikipedia.org/wiki/Control_register 
      - http://wiki.osdev.org/CPU_Registers_x86
- ELF format
  - http://wiki.osdev.org/ELF
  - https://en.wikipedia.org/wiki/Executable_and_Linkable_Format
  - http://www.sco.com/developers/gabi/latest/contents.html
  - http://stackoverflow.com/questions/3065535/what-are-the-meanings-of-the-columns-of-the-symbol-table-displayed-by-readelf
- Linker script
  - http://wiki.osdev.org/Linker_Scripts
  - binutils ld: https://sourceware.org/binutils/docs/ld/index.html
- GRUB syntax/configuration
  - GRUB multiboot: https://www.gnu.org/software/grub/manual/multiboot/multiboot.html
  - https://www.gnu.org/software/grub/manual/html_node/index.html
  - https://www.gnu.org/software/grub/manual/html_node/Multi_002dboot-manual-config.html
  - http://www.ibm.com/developerworks/linux/library/l-bootload/index.html
- VGA:
  - http://wiki.osdev.org/Text_UI
  - https://en.wikipedia.org/wiki/VGA-compatible_text_mode
- Keyboard Input:
  - http://www.osdever.net/bkerndev/Docs/keyboard.htm
- Timer Chipe (PIC):
  - http://www.osdever.net/bkerndev/Docs/pit.htm
- gcc inline assembly:
  - https://gcc.gnu.org/onlinedocs/gcc-4.8.5/gcc/Extended-Asm.html
  - `__attribute__((packed))`: https://gcc.gnu.org/onlinedocs/gcc/Common-Type-Attributes.html
- C language 
  - Compiler, Assembler, Linker, and Loader: http://www.tenouk.com/ModuleW.html
  - C header files: https://www.gnu.org/software/libtool/manual/html_node/C-header-files.html
  - stdio.h: https://en.wikibooks.org/wiki/C_Programming/C_Reference/stdio.h
  

### TODO

- how to reproduce zero exception loop? (I saw this output one time, but it's not saved as commit)

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/06/2016-06-18_1115.png"><img src="http://wp.hiogawa.net/wp-content/uploads/2016/06/2016-06-18_1115-1024x600.png" alt="2016-06-18_1115" width="580" height="340" class="alignnone size-large wp-image-728" /></a>

- handle zero exception after `sti`
- Run on real hardware


### Further Learning

- read official document: http://www.intel.com/content/www/us/en/processors/architectures-software-developer-manuals.html
- Memory management: Paging vs Segmentation
  - http://wiki.osdev.org/Paging
  - http://wiki.osdev.org/Segmentation
- DIY Boot Loader
  - Writing a bootloader from scratch: https://www.cs.cmu.edu/~410-s07/p4/p4-boot.pdf
  - http://wiki.osdev.org/Boot_Sequence
  - http://wiki.osdev.org/Rolling_Your_Own_Bootloader
  - http://www.ibm.com/developerworks/library/l-linuxboot/index.html
- Understand Emulater/Virtualization
  - http://serverfault.com/questions/208693/difference-between-kvm-and-qemu
- toward 64 bit hardware
- toward Linux
  - Linux kernel module
  - POSIX System Call
  - https://www.quora.com/What-are-good-ways-to-understand-the-Linux-kernel
- LLVM 
- Carnegie Mellon OS class: https://www.cs.cmu.edu/~410-s07/



## Tips

### Commands

- `gcc`:
  - options:
      - `-v`: verbose
      - `-E`: only do _preprocess_ (output goes to stdout)
      - `-S`: only do _compile_ (generates `.s` file)
      - `-lgcc`:
           - https://gcc.gnu.org/onlinedocs/gccint/Libgcc.html
           - http://wiki.osdev.org/Libgcc

Below are from `man gcc`:

>       -fhosted
           Assert that compilation targets a hosted environment.  This implies -fbuiltin.  A
           hosted environment is one in which the entire standard library is available, and in
           which "main" has a return type of "int".  Examples are nearly everything except a
           kernel.  This is equivalent to -fno-freestanding.

>       -ffreestanding
           Assert that compilation targets a freestanding environment.  This implies
           -fno-builtin.  A freestanding environment is one in which the standard library may
           not exist, and program startup may not necessarily be at "main".  The most obvious
           example is an OS kernel.  This is equivalent to -fno-hosted.

>       -nostdlib
           Do not use the standard system startup files or libraries when linking.  No startup
           files and only the libraries you specify are passed to the linker, and options
           specifying linkage of the system libraries, such as "-static-libgcc" or
           "-shared-libgcc", are ignored.
           The compiler may generate calls to "memcmp", "memset", "memcpy" and "memmove".
           These entries are usually resolved by entries in libc.  These entry points should
           be supplied through some other mechanism when this option is specified.
           One of the standard libraries bypassed by -nostdlib and -nodefaultlibs is libgcc.a,
           a library of internal subroutines which GCC uses to overcome shortcomings of
           particular machines, or special needs for some languages.
           In most cases, you need libgcc.a even when you want to avoid other standard
           libraries.  In other words, when you specify -nostdlib or -nodefaultlibs you should
           usually specify -lgcc as well.  This ensures that you have no unresolved references
           to internal GCC library subroutines.  (An example of such an internal subroutine is
           __main, used to ensure C++ constructors are called.)


- `hexdump`, `hd`:
  - options:
      - `-C`: show ascii on the right (`hd` set this option by default)
      - `-v`: show all data
      - `-s`: offset from start (you can specify in hex by adding _0x_)
      - `-n`: number of bytes to show
  - I usually use in this form: `hexdump -Cv <binary file> | less`

- `readelf`:
  - options:
      - `-h`: elf header (a.k.a. file header)
      - `-l`: program header
      - `-S`: section header
      - `-s`: symbol table
      - `-a`: all headers information
      - `-W`: print in wide format (not truncate line each 80 character)


Below are examples of _readelf_, _hexdump_:

```
$ readelf -SsW boot.o
There are 10 section headers, starting at offset 0x178:

Section Headers:
  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
  [ 0]                   NULL            00000000 000000 000000 00      0   0  0
  [ 1] .text             PROGBITS        00000000 000034 00000e 00  AX  0   0  1
  [ 2] .rel.text         REL             00000000 00011c 000010 08   I  8   1  4
  [ 3] .data             PROGBITS        00000000 000042 000000 00  WA  0   0  1
  [ 4] .bss              NOBITS          00000000 000042 000000 00  WA  0   0  1
  [ 5] .multiboot        PROGBITS        00000000 000044 00000c 00      0   0  4
  [ 6] .bootstrap_stack  NOBITS          00000000 000050 004000 00  WA  0   0  1
  [ 7] .shstrtab         STRTAB          00000000 00012c 00004c 00      0   0  1
  [ 8] .symtab           SYMTAB          00000000 000050 0000a0 10      9   8  4
  [ 9] .strtab           STRTAB          00000000 0000f0 00002b 00      0   0  1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings)
  I (info), L (link order), G (group), T (TLS), E (exclude), x (unknown)
  O (extra OS processing required) o (OS specific), p (processor specific)

Symbol table '.symtab' contains 10 entries:
   Num:    Value  Size Type    Bind   Vis      Ndx Name
     0: 00000000     0 NOTYPE  LOCAL  DEFAULT  UND 
     1: 00000000     0 SECTION LOCAL  DEFAULT    1 
     2: 00000000     0 SECTION LOCAL  DEFAULT    3 
     3: 00000000     0 SECTION LOCAL  DEFAULT    4 
     4: 00000000     0 SECTION LOCAL  DEFAULT    5 
     5: 00000000     0 SECTION LOCAL  DEFAULT    6 
     6: 00000000     0 NOTYPE  LOCAL  DEFAULT    6 stack_bottom
     7: 00004000     0 NOTYPE  LOCAL  DEFAULT    6 stack_top
     8: 00000000     0 NOTYPE  GLOBAL DEFAULT    1 _start
     9: 00000000     0 NOTYPE  GLOBAL DEFAULT  UND kernel_main
```

The columns appearing in _Symbol table_ mean:

- `Ndx`: the number of section including the symbol,
- `Value`: the offset of the symbol from the start of its section.

If you want to see what's written on `.multiboot` section, you can hexdump the file as below:

```
$ hd -s 0x44 -n 12 boot.o
00000044  02 b0 ad 1b 03 00 00 00  fb 4f 52 e4              |.........OR.|
00000050
```

For an executable file, `readelf` also shows information about an memory address for each section to be loaded (which is called _program headers_):

```
$ readelf -lSW myos.bin
There are 9 section headers, starting at offset 0x160c:

Section Headers:
  [Nr] Name              Type            Addr     Off    Size   ES Flg Lk Inf Al
  [ 0]                   NULL            00000000 000000 000000 00      0   0  0
  [ 1] .text             PROGBITS        00100000 001000 000201 00  AX  0   0 4096
  [ 2] .rodata.str1.4    PROGBITS        00100204 001204 000024 01 AMS  0   0  4
  [ 3] .eh_frame         PROGBITS        00100228 001228 000110 00   A  0   0  4
  [ 4] .bss              NOBITS          00101000 002000 004010 00  WA  0   0 4096
  [ 5] .comment          PROGBITS        00000000 001338 000011 01  MS  0   0  1
  [ 6] .shstrtab         STRTAB          00000000 0015c3 000048 00      0   0  1
  [ 7] .symtab           SYMTAB          00000000 00134c 000180 10      8  10  4
  [ 8] .strtab           STRTAB          00000000 0014cc 0000f7 00      0   0  1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings)
  I (info), L (link order), G (group), T (TLS), E (exclude), x (unknown)
  O (extra OS processing required) o (OS specific), p (processor specific)

Elf file type is EXEC (Executable file)
Entry point 0x10000c
There are 2 program headers, starting at offset 52

Program Headers:
  Type           Offset   VirtAddr   PhysAddr   FileSiz MemSiz  Flg Align
  LOAD           0x001000 0x00100000 0x00100000 0x00338 0x00338 R E 0x1000
  LOAD           0x002000 0x00101000 0x00101000 0x00000 0x04010 RW  0x1000

 Section to Segment mapping:
  Segment Sections...
   00     .text .rodata.str1.4 .eh_frame 
   01     .bss 
```

The columns apearing in `Section Headers:` mean:

- `Addr`: memory address where the section will be loaded,
- `Off`: location of data in a binary file.

So, if you want to see real data from `hexdump`, you'll specify the value of `Off` as an option as below:

```
$ hd -s 0x01000 -n 4 myos.bin
00001000  02 b0 ad 1b                                       |....|
```

### Hex Numbers Translation

While reading those articles, I had a problem reading hex numbers. Here is a little hint:

```
- 0x1(0 * n) = 2^(4*n) B
- 0x1000 = 2^(4*3) B = 2^12 B = (2^10) * 4 B = 4KiB 
- 0x100000 = 2^(4*5) B = 2^20 B = (2^10) * (2^10) B = 1MiB

- 0x00000400 = 2^(4*2) * 4 B = 1Kib
- 0x00100000 = 2^(4*5) B = 2^20 B = (2^10) * (2^10) B = 1MiB
- 0x40000000 = 1GiB
- 0xFFFFFFFF ~ 4GiB 
```