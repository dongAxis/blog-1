<!--
{
  "title": "File system",
  "date": "2017-04-10T21:09:50+09:00",
  "category": "",
  "tags": ["linux", "filesystem"],
  "draft": true
}
-->


# Virtual file system

Linux source:

```
- fs/
  - KConfig, Makefile
  - open.c, read_write.c, readdir.c (open, getdents)
  - namespace.c (mount)
  - super.c (mount_fs)
  - inode.c, dcache.c
  - filesystem.c (register_filesystem)
  - mount.h (struct mnt_namespace, mountpoint, mount)

- block/
  - KConfig, Makefile

- include/linux/
  - fs.h (struct file_system_type, block_device, inode, super_block)
  - dcache.h (struct dentry, dentry_operations)
  - mount.h (struct vfsmount)
```


Following some parts:

```
[ file system registration ]
register_filesystem


[ mount ]
- SYSCALL_DEFINE5(mount, ...) => do_mount => do_new_mount =>
  - struct vfsmount *mnt = vfs_kern_mount =>
    - struct dentry *root = mount_fs =>
      - struct mount *mnt = alloc_vfsmnt
      - struct dentry *root = file_system_type.mount => [ mount implementation ]
      - (at this point, we already have super_block as root->d_sb)
  - do_add_mount =>
    - graft_tree => attach_recursive_mnt =>
      - ... namespace and all that


[ mount implementation ]
- ? =>
  - leads to mount_bdev with some fill_super ?


[ open ]
- SYSCALL_DEFINE3(open, ...) => do_sys_open =>
  - build_open_flags (could return error for invalid flag)
  - getname => ?
  - get_unused_fd_flags => __alloc_fd
  - do_filp_open =>
    - struct nameidata on stack
    - set_nameidata
    - struct file *filp = path_openat =>
      - get_empty_filp => check file descriptor upper limit and kmem_cache_zalloc
      - path_init =>
        - setup nameidata's starting dentry (e.g. set nd->inode to current->fs->pwd)
      - (this looks not so trivial. should refer to Documentation/filesystems/path-lookup.txt.)
      - link_path_walk =>
        - walk_component (follow directory one deep?) =>
          - lookup_fast (follow next deeper dentry) => __d_lookup =>
          - step_into (update nameidata)
        - d_can_lookup
      - do_last =>
        - lookup_fast
        - lookup_open => ?
        - step_into
        - complete_walk
        - may_open
        - vfs_open(path, dentry) =>
          - do_dentry_open(file, d_backing_inode(dentry)) =>
            - f->f_op = fops_get(inode->i_fop)
            - f->f_op->open(inode, file) => [ open implementation ]
  - fsnotify_open (will lead to inotify)
  - fd_install (I saw this for socket sycall too)

Q.
- do we get multibyte character file path right ?
  - as long as we can recognize "/" and "." as single byte, is it fine ?
- use of inode_operations.lookup
- open special files (e.g. character or block devices)
- use of dcache api (e.g. d_lookup, d_add, d_instantiate)


[ open implementation ]
- (find example ...)


[ read ]


[ write ]


[ getdents ]



[ Data structures ]

file_system_type
'-' mount operation

mount
'-' mount (to parent)
'-' dentry (mountpoint)
'-' vfsmount

vfsmount
'-' dentry (where it's mounted)
'-' super_block

super_block
'-' dentry (as root)
'-' super_operations (e.g. alloc_inode ...)

dentry
'-' inode
'-' dentry (to parent)
'-' dentry_operations (e.g. ?)

inode
'-' inode_operations (e.g. lookup, create, mkdir)
'-' file_operations (passed to file)
'-' address_space (for page cache ?)
  '-' address_space_operations (e.g. writepage, readpage)

path
'-' dentry
'-' vfsmount

file
'-' file_operations (e.g. open, read, write)
'-' path
'-' inode
```


# Block layer and disk file system

Some relevant kernel source:

```
- include/linux/
  - genhd.h (struct partition, hd_struct, gendisk)
  - blkdev.h (struct request, request_queue)
  - bvec.h (struct bio_vec)
  - blk_types.h (struct bio)
  - bio.h (?)
  - buffer_head.h (buffer_head)

- include/linux
  - types.h (sector_t)

- drivers/ata/ahci.c,.h, libahci.c,.h

- fs/ext4/
```


## Initialization

Driver

```
- module_pci_driver(ahci_pci_driver) (macro to module_init)
- ahci_init_one (as ahci_pci_driver.probe) =>
  - (a bunch of pdev->vendor checking)
  - ahci_host_activate => ???

- ? register_blkdev
- ? alloc_disk, add_disk
- ?  blk_init_queue(foo_strategy

- boot phase or initram ?
- Q. How does it expose paritions ?
```

```
[ open and mount ]
- dentry_open => blkdev_open => ...?

[ read ]

[ write ]
```


## IO Request

- how does kernel dispatch work to block device driver ?
 - kernel thread ? work queue ?
 - kblockd ?  kblockd_workqueue ?

```
[ Data structure ]
gendisk
'-' request_queue
  '-* request
    '-* bio
      '-* bio_vec
        '-' page
'-* hd_struct (partitions)

block_device
'-' block_device (parent if this is partition)
'-' hd_struct (parititon if this is partition)
'-' gendisk
'-' request_queue (same to gendisk's request_queue ?)
'-' super_block (is this for filesystem ?)

cf.
- Understanding The Linux Kernel (3rd Edition)
  - Figure 14-3. Linking the block device descriptors with the other structures of the block subsystem
```

```
[ Generic block layer IO interface ]
here, entry point can be:
1. accessing block device file directly (e.g. open '/dev/sda'), or
2. accesing regular file under block-based file system.

- (some entry ?) =>
  - bio_alloc
  - generic_make_request =>
    - blk_partition_remap
    - request_queue.make_request_fn (i.e. ?) =>


[ IO schedular ]
- ? => __make_request =>
  - elv_queue_empty
  - blk_plug_device
  - elv_merge
  - merge case:
    - done?
  - non merge case:
    - alloc request and push ?

- (unplug timer elapsed) =>
  - ? request_queue.request_fn


[ Device driver ]
- ? request_fn, strategy execution (handle request_queue) =>
  - ?
  - elv_next_request
  - blk_fs_request
  - blk_rq_map_sg (scatter-gather DMA)
- ? hardware interrupt notifies data transfer finishes =>
  - end_that_request_first,_last =>
    - update bios in request (e.g. remove finished bio)
    - bio_endio (for finished bio) => ?
  - continue request_fn if there's still any request left
```


## Simple example without filesystem

```
$ sudo head -c 1K /dev/sda | hd
...
00000200  45 46 49 20 50 41 52 54  00 00 01 00 5c 00 00 00  |EFI PART....\...|

Q.
- try some similar write operation with some USB flash
```

```
- syscall open '/dev/sda'
- syscall read
```


## Some stats on my machine

Q.
- sector
  - the location of stuff on disk ?
  - sector_t
- block (of file system)
  - memory for contigous sectors
  - unit of file system (or any block layer user?) IO operation
  - buffer_head
  - logical block number ?
  - is this `bio_vec` (before possible merge) ?
- segment
  - unit of device driver IO operation (for scatter-gather, they handel multiple segments)
  - is this single `bio_vec` (after merge) ?

```
$ lspci -s 00:17.0 -v
00:17.0 SATA controller: Intel Corporation Sunrise Point-LP SATA Controller [AHCI mode] (rev 21) (prog-if 01 [AHCI 1.0])
	Subsystem: Lenovo Sunrise Point-LP SATA Controller [AHCI mode]
	Flags: bus master, 66MHz, medium devsel, latency 0, IRQ 277
	Memory at f1148000 (32-bit, non-prefetchable) [size=8K]
	Memory at f1150000 (32-bit, non-prefetchable) [size=256]
	I/O ports at e080 [size=8]
	I/O ports at e088 [size=4]
	I/O ports at e060 [size=32]
	Memory at f114e000 (32-bit, non-prefetchable) [size=2K]
	Capabilities: <access denied>
	Kernel driver in use: ahci
	Kernel modules: ahci

$ modinfo ahci | head
filename:       /lib/modules/4.8.0-49-generic/kernel/drivers/ata/ahci.ko
version:        3.0
license:        GPL
description:    AHCI SATA low-level driver
author:         Jeff Garzik
srcversion:     E0A87435109F7A1BCF367EB
alias:          pci:v*d*sv*sd*bc01sc06i01*
alias:          pci:v00001C44d00008000sv*sd*bc*sc*i*
alias:          pci:v0000144Dd0000A800sv*sd*bc*sc*i*
alias:          pci:v0000144Dd00001600sv*sd*bc*sc*i*

$ lsmod | grep ahci
ahci                   36864  3
libahci                32768  1 ahci

$ blkid
/dev/sda1: LABEL="SYSTEM" UUID="2068-1F24" TYPE="vfat" PARTUUID="e0e41ced-be5f-4291-bd68-2d5de843a588"
/dev/sda2: UUID="0b6a2d2e-2e49-49cf-ba06-e29322624dc9" TYPE="swap" PARTUUID="3d667494-9f0b-4460-b5ee-50c71ab21359"
/dev/sda3: UUID="53fb1dc7-e008-4dfc-ae2c-ce8e8849992e" TYPE="ext4" PARTUUID="73770d23-7412-445b-b5dd-76c1ae54f457"

$ sudo fdisk -l /dev/sda
Disk /dev/sda: 465.8 GiB, 500107862016 bytes, 976773168 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: gpt
Disk identifier: 81FF4D55-217A-4DD9-B57A-902F86F5A487

Device        Start       End   Sectors  Size Type
/dev/sda1      2048    534527    532480  260M EFI System
/dev/sda2    534528  17311743  16777216    8G Linux swap
/dev/sda3  17311744 554182655 536870912  256G Linux filesystem
```


# Block-based filesystem

- ext4
- on disk format
- mount process
- inode and dentry (creation deletion)
- read and write


```
$ (create new partition /dev/sda4 from cfdisk)
$ sudo partprobe /dev/sda
$ sudo fdisk -l | grep /dev/sda4
/dev/sda4  554182656 562571263   8388608    4G Linux filesystem
$ sudo mkfs.btrfs -f /dev/sda4
btrfs-progs v4.7.3
See http://btrfs.wiki.kernel.org for more information.

Detected a SSD, turning off metadata duplication.  Mkfs with -m dup if you want to force metadata duplication.
Performing full device TRIM (4.00GiB) ...
Label:              (null)
UUID:               
Node size:          16384
Sector size:        4096
Filesystem size:    4.00GiB
Block group profiles:
  Data:             single            8.00MiB
  Metadata:         single            8.00MiB
  System:           single            4.00MiB
SSD detected:       yes
Incompat features:  extref, skinny-metadata
Number of devices:  1
Devices:
   ID        SIZE  PATH
    1     4.00GiB  /dev/sda4
$ mkdir -p ~/btrfs_test_root
$ sudo mount -t btrfs /dev/sda4 ~/btrfs_test_root
$ cd ~/btrfs_test_root
$ sudo mkdir -p user_dir
$ sudo chown -R $(whoami):$(whoami) user_dir
$ echo 'hello world' > user_dir/test.txt
$ cat user_dir/test.txt
$ sudo head -c 100K /dev/sda4 | hd
00010040  5f 42 48 52 66 53 5f 4d  0f 00 00 00 00 00 00 00  |_BHRfS_M........|
```


# LVM or RAID implementation


# FUSE (Filesystem in USEr space)

```
(fs/fuse/inode.c)
- module_init(fuse_init) =>
  - fuse_fs_init => register_filesystem(&fuse_fs_type)
```


# TODO

- implementation of fdisk, partprobe, mkfs.xxx


# Reference

- LDD3
  - block things ...
- https://btrfs.wiki.kernel.org/index.php/Main_Page
- http://www.rodsbooks.com/gdisk/index.html
- Documentation/filesystems
  - vfs.txt
  - path-lookup.txt, path-lookup.md
