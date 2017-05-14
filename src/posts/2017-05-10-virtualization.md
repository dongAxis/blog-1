<!--
{
  "title": "Virtualization",
  "date": "2017-05-10T13:49:57+09:00",
  "category": "",
  "tags": ["linux"],
  "draft": true
}
-->

# TODO

- virtual box
- qemu
- kvm
- xen


# amd64

- System programming: http://support.amd.com/TechDocs/24593.pdf
  - 1. System programming overview
  - 2 x86 and AMD64 Architecture Differences
    - 2.6 Interrupts and Exceptions
    - 2.6.2 Stack Frame Pushes
    - 2.6.3 Stack Switching
  - 3. System resource
  - 4. Segmented Virtual Memory
    - 4.4 Segmentation Data Structures and Registers
    - 4.5.3 Segment Registers in 64-Bit Mode
    - 4.9 Segment-Protection Overview
    - 4.9.1 Privilege-Level Concept
  - 5 Page Translation and Protection
    - 5.6 Page-Protection Checks
  - 8. Exceptions and Interrupts
    - 8.9 Long-Mode Interrupt Control Transfers
    - 8.9.3 Interrupt Stack Frame
      - how stack and register changes
      - IST and TSS is referenced for stack switch
        (this is used for switching from user process's stack to kernel stack ?)
    - Figure 8-13. Long-Mode Stack After Interrupt—Same Privilege
    - Figure 8-14. Long-Mode Stack After Interrupt—Higher Privilege
  - 15. Secure Virtual Machine


# Virtual box

- references
  - https://www.virtualbox.org/wiki/Linux%20build%20instructions
  - https://www.virtualbox.org/manual/ch10.html
  - https://www.virtualbox.org/manual/ch08.html
  - https://superuser.com/questions/712446/how-do-i-manage-multiple-kernel-modules-by-the-same-name
- dkms autoinstall

```
$ (build from source)

$ (build kernel module from source)

$ (update depmod.d)
# /etc/depmod.d/ubuntu.conf
search misc updates ubuntu built-in

$ ./VBox.sh
```
