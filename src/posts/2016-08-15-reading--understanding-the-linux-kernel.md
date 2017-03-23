<!--
{
  "title": "Reading: Understanding the Linux Kernel",
  "date": "2016-08-15T18:48:38.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

Kernel versions: https://github.com/torvalds/linux/commit/194dc870a5890e855ecffb30f3b80ba7c88f96d6

After I got through [my bare bones os](http://wp.hiogawa.net/2016/06/19/os-development-starter/), it's time to start to understand Linux OS.

Somehow I got a couple of books:

- Understanding the Linux Kernel: http://shop.oreilly.com/product/9780596005658.do

- Understanding Linux Network Internals: https://www.amazon.com/Understanding-Network-Internals-Christian-Benvenuti/dp/0596002556
- Linux Kernel Development: https://www.amazon.com/Linux-Kernel-Development-Robert-Love/dp/0672329468
- Linux Device Drivers: https://lwn.net/Kernel/LDD3/


I decided to go through _Understanding the Linux Kernel_ first. 
As a normal Linux user doing a bit of DevOps work, here is the order of chapters I'm fascinated to read:

- 1 Overview
  - 1.6 Process/Kernel

- 3 Processes
  - [should skim whole pages]

- 2 Memory Addressing
  - 2.1 Logical, Linear, Physical addresses
  - 2.4 Paging in Hardware
  - 2.5 Paging in Linux

- 6 Memory Management (kernel point of view, not a process)
  - 6.1 page frame
  - 6.2 memory area (slab allocation)
  - 6.3 noncontiguous memory area 

| type | structures                           | interfaces                                                 |
|-------|:------------------------------------- |:------------------------------------------------------:|
| 6.1 | page                                      | __get_free_pages, free_pages               |
| 6.2 | kmem_cache/slab/bufctl_s| kmem_cache_alloc/free, kmalloc/free |
| 6.3 | vm_struct                             | vmalloc/free                                             |

- 7 Process Address Space
  - structures
      - memory descriptor`mm_struct`
      - memory region `vm_area_struct`
  - interfaces
      - `do_map` (enlarge process's address space) , `ddo_unmap` (shrink)
      - `do_mmap`, `do_munmap`
          - who is calling those functions? what triggers these functions? (system call `brk` or when kernel notices user mode stack is not enough)
  - process virtually already has 4GB
    but it needs to request to explicitly manage memory usage.
    process is created (get `mm_struct`) ->
    further memory request (request memory region in the form of `vm_area_struct`) -> 
    physically allocate memory (page frame) only when requested memory region is used (page fault handler) 

- 9 Signals
   
- 12 The Virtual Filesystem

- 13 Managing I/0 Devices

- 4 Interrupts and Exceptions

- 8 System Calls

--- 

- 18 Process Communication

- 19 Program Execution

- Appendix A. System Startup
- Appendix B. Modules