<!--
{
  "title": "Dealing with peripherals",
  "date": "2017-01-13T20:01:33.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

Assume: x86 and PCI

- Basic flow:
  - check spec of the location of the bus memory for periperal
  - request_mem_region
  - ioremap
  - ioread, iowrite
  - (how about DMA ? is it the concept specific to certain bus (e.g. PCI) ?)

- Starting Point
  - /proc/iomem, /proc/ioports
  - /proc/bus/
  - /sys/...?

- PCI
  - initialization:
    - firmware: (how is configuration space setup ?)
    - kernel: `allocate I/O and memory regions of the device (if BIOS did not)` ?
      - is it allocation to physical address ?
  - how device (5bit), function (3bit) is defined ? (is this hardcoded on the board ?)
  - how to talk to pci device => how to talk to pci bus => how to talk to pci controller or whatever managing bus
    - how to manage device pci configuration registers ?
  - what is "memory controller" showing up as PCI device

- other "modern" bus if there is ?

- Example: keyboard device
  - initialization:
    - device identification => load driver => initialize device =>

- Example: video card

- Questions
  - is io port hard-coded to hardware ?
    - I mean, which IO port connects to what is defined by what ? (intel board spec or pc vendor ?)
      - what is that even ?
  - memory mapped 
  - how much is it different if we use ARM kernel ?
  - firmware(BIOS)
  - definition of SoC ("platform bus" vs "pci bus" ?)


- Reference:
  - LDD3 (Chapter 9: Communicating with Hardware)
  - Documentation
    - io-mapping.txt
    - DMA-API.txt
    - PCI/
    - driver-model
    - x86/x86_64/mm.txt
    - Intel