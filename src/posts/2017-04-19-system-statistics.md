<!--
{
  "title": "System (Process) Statistic in Linux",
  "date": "2017-04-19T15:14:40+09:00",
  "category": "",
  "tags": ["source", "linux"],
  "draft": true
}
-->

# Reading htop

Obtainable process's attributes:

- ProcessFieldData Process_fields[] (linux/LinuxProcess.c)

- struct Process_, enum ProcessFields (Process.h)
  - e.g. percent_cpu, percent_mem

- struct LinuxProcess_, enum LinuxProcessFields (linux/LinuxProcess.h)
  - e.g. utime, stime, ioPriority


How htop gets them (read `man 5 proc`):

- /proc/stat
- /proc/meminfo
- /proc/loadavg
- /proc/[pid]/stat
- /proc/[pid]/statm
- /proc/[pid]/environ
- /proc/[pid]/task/[tid]


Roughly follow from main:

```
- main =>
  - (skip some UI things ...)
  - ProcessList_new (LinuxProcessList.c) =>
    - ProcessList_init
    - LinuxProcessList_initTtyDrivers => (read /proc/tty/drivers)
    - read /proc/stat and check the number of CPUs
  - ProcessList_scan => ProcessList_goThroughEntries (LinuxProcessList.c) =>
    - LinuxProcessList_scanMemoryInfo =>
      - read /proc/meminfo and update ProcessList.usedMem, cachedMem, usedSwap
    - LinuxProcessList_scanCPUTime =>
      - read /proc/stat and update ProcessList.userPeriod, userTime, systemPeriod, systemTime, etc...
        (Period version is a diff from previous scan)
    - LinuxProcessList_recurseProcTree =>
      - ProcessList_getProcess => LinuxProcess_new (just construct data structure)
      - LinuxProcessList_recurseProcTree (for /proc/[pid]/task) =>
      - LinuxProcessList_readIoFile =>
        - read /proc/[pid]/io and update Process.io_read_bytes, io_write_bytes
      - LinuxProcessList_readStatmFile =>
        - read /proc/[pid]/statm and update Process.m_size, m_resident and others
      - LinuxProcessList_readStatFile =>
        - read /proc/[pid]/stat and update Process.state, utime, stime and others
      - calculate Process.percent_cpu from Process.utime, stime and "period" we got from LinuxProcessList_scanCPUTime
      - calculate Process.percent_mem from Process.m_resident and ProcessList.totalMem
      - LinuxProcessList_statProcessDir (for new process (not existed before) =>
        - stat(/proc/[pid]) and update Process.st_uid, starttime_ctime
      - (some other proc file too (e.g. cgroup). I'll skip those here)
```


# TODO

- proc filesystem
  - /proc/[pid]/
    - fd, fdinfo
    - io
    - stat, statm, status
    - task/[tid]/
  - /proc/meminfo
  - /proc/net/
    - ...
  - /proc/stat

- Kernel (subsystem)
  - fs/proc/*
  - ?

# CPU

- Kernel thread: pgrp is 0
- CPU Usage
  - low/normal/kernel/irq/soft-irq/steal/guest/io-wait

- Linux process scheduling
  - idle task
    - is there really no process/thread to run when kernel is scheduling "idle task" ?
    - this happens when "run queue" is literally empty ?
  - how can we throttle process's cpu time ?


# Memory

- used/buffers/cache + swap
  - read /proc/meminfo in `man 5 proc`

- low/high mem in 64bit
  - not relevant when physical memory is smaller than virtual memory
  - https://www.kernel.org/doc/Documentation/vm/highmem.txt

- TODO: summerize kmalloc and vmalloc
  - kmalloc: these part of memory are directly mapped from physical memory (so, it's not relocatable using page table ?)
  - vmalloc: can be relocatable and swappable ?
  - what kind of process entity will be used for vmalloc and for kmalloc ?


# File

- utility
  - lsof

- anything with file descriptor abstraction ?


# Network

- hardware bandwidth
- utility
  - bmon: per interface
  - iftop: per socket
  - nethogs: per process
- kernel subsystem (socket, tcp, ip implementation)


# Storage and (block) file system

- utility
  - df, fdisk
  - iostat (from systat)
  - iotop

- /sys/block/<dev>/stat

- kernel subsystem


# Reference

- Documentation/
  - [x86/x86_64/mm.txt](https://www.kernel.org/doc/Documentation/x86/x86_64/mm.txt)
  - [vm/highmem.txt](https://www.kernel.org/doc/Documentation/vm/highmem.txt)
  - [block/stat.txt](https://www.kernel.org/doc/Documentation/block/stat.txt)
  - [iostats.txt](https://www.kernel.org/doc/Documentation/iostats.txt)
- [man 5 proc](http://man7.org/linux/man-pages/man5/proc.5.html)
- http://www.binarytides.com/linux-commands-monitor-network/
