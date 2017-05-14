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
- how to open character or block devices files (udev filesystem ?)
- use of dcache api (e.g. d_lookup, d_add, d_instantiate)


[ read ]
- SYSCALL_DEFINE3(read,...) =>
  - fdget_pos => ... get struct file from curret->files
  - file_pos_read
  - vfs_read => __vfs_read =>
    - file->f_op->read => [ read impl ]
  - file_pos_write

[ write ]
- SYSCALL_DEFINE3(write,...) =>
  - vfs_write =>
    - file_start_write => __sb_start_write ?
    - __vfs_write => file->f_op->write

[ getdents ]
- SYSCALL_DEFINE3(getdents,...) =>
  - struct getdents_callback with filldir
  - iterate_dir => file->f_op->iterate => ...


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

- drivers/ata/ahci.c, libahci.c
- drivers/scsi/sd.c

- fs/ext4/
```


## Block device file/driver

Q. what's about ahci and scsi ?
Q. what kind of kernel help does udevd need ?
  - netlink
  - it's not really symlink files under /dev ?
  - what does it mean `df` shows `udev` filesystem but there's not in /proc/filesystems ?

```
[ Initialization ]
- init_sd =>
  - register_blkdev
  - blk_register_region(sd_default_probe, ...) =>
  - class_register
  - scsi_register_driver => driver_register

- scsi_add_device (I don't know how this bus's device is detected...)
  - __scsi_add_device
    - scsi_probe_and_add_lun
      - scsi_alloc_sdev =>
        - struct scsi_device *sdev = kzalloc
        - sdev->request_queue = scsi_alloc_queue =>
          - struct request_queue *q = blk_alloc_queue_node
          - q->request_fn = scsi_request_fn
          - blk_queue_xxx calls
      - scsi_probe_lun =>
        - scsi_execute
          - blk_execute_rq => (is this really going to trigger sd_probe ...?)

- sd_probe (as sd_template.gendrv.probe) =>
  - (Q. when did we allocate memory for struct scsi_device ? e.g. request_queue field)
  - struct gendisk *gd = alloc_disk
  - blk_queue_rq_timeout
  - device_initialize, device_add, dev_set_drvdata
  - async_schedule_domain(sd_probe_async, ...) =>
    - (then maybe later on)
    - sd_probe_async =>
      - gd->fops = &sd_fops
      - gd->queue = sdkp->device->request_queue
      - sd_revalidate_disk => sd_spinup_disk ?
      - device_add_disk =>
        - blk_register_region
        - register_disk =>
          - device_add
          - disk_part_iter_init =>
        - blk_register_queue =>
          - blk_wb_init
          - elv_register_queue

- Q. when did we allocate struct block_device ?


[ open impl ]
(path lookup (or dentry/inode discovery phase))
- ramfs_get_inode (just guessing this is somehow called ...)
  - init_special_inode =>
   - inode->i_fop = &def_blk_fops

- SYSCALL_DEFINE3(open, ...) => ... =>
  - vfs_open => do_dentry_open =>
    - f->f_op->open (i.e. blkdev_open) =>
      - struct block_device *bdev = bd_acquire =>
      - blkdev_get => __blkdev_get =>
        - struct gendisk *disk = get_gendisk
        - disk->fops->open (i.e. sd_open) =>
          - (sd_open only does some checking ?)

[ read impl ]

[ write impl ]
```


## Block-based filesystem (Ext4)

- on-disk format: https://ext4.wiki.kernel.org/index.php/Ext4_Disk_Layout
- on-memory vs on-disk
  - e.g. ext4_sb_info (memory) and ext4_super_block (disk)
- start from e2fsprogs (e.g. e2fsck, mke2fs, dumpe2fs)
- understand ex4 feature
  - journaling ?

```
[ registration ]
- module_init(ext4_init_fs) =>
  - init_waitqueue_head
  - register_filesystem(&ext4_fs_type)


[ mount impl ]
- SYSCALL_DEFINE5(mount, ...) => ... => mount_fs => ... =>
  - struct dentry *root = file_system_type.mount (i.e. ext4_mount) =>
    - mount_bdev(ext4_fill_super, ...) =>
      - struct block_device *bdev = blkdev_get_by_path =>
        - lookup_bdev and blkdev_get (we saw this above "block device file open impl")
      - struct super_block *s = sget => sget_userns =>
        - struct super_block *s = alloc_super => kzalloc
      - ext4_fill_super (as fill_super) =>
        - ext4_fsblk_t sb_block = get_sb_block(&data) (by default 1, but mount option could change it)
        - struct ext4_sb_info *sbi = kzalloc
        - assuming block_size is 4096, then after some simple arithmetic,
          logical_sb_block = 0
          offset = 1024
        - struct buffer_head *bh = sb_bread_unmovable(sb, logical_sb_block) => __bread_gfp
        - struct ext4_super_block *es = (struct ext4_super_block *) (bh->b_data + offset)
        - ... huge configuration check ...
        - sb->s_op = &ext4_sops
        - root = ext4_iget(sb, EXT4_ROOT_INO) (i.e. 2) => (SEE BELOW)
        - sb->s_root = d_make_root(root) => __d_alloc and d_instantiate (dcache api, I'll look after later...)
        - ext4_setup_super =>
        - ext4_register_sysfs(sb) =>

- ext4_iget =>
  - struct inode *inode = iget_locked => when it's not cached alloc_inode
  - struct ext4_inode_info *ei = EXT4_I(inode)
    - (this cannot be the first time? we have to allocate ext4_inode_info and give it to vfs?)
  - __ext4_get_inode_loc(struct ext4_iloc *iloc) => ...
  - struct ext4_inode *raw_inode = ext4_raw_inode => ...


[ inode and dentry lookup ]

[ inode and dentry creation ]

[ open impl ]

[ read impl ]
? generic_file_read
readpage


[ write impl ]
? generic_file_write
```


## IO Request

- how does kernel dispatch work to block device driver ?
 - kernel thread ? work queue ?
 - kblockd ?  kblockd_workqueue ?

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
[ Data structure ]
gendisk
'-' request_queue
  '-* request
    '-* bio
      '-* bio_vec
        '-' page
'-* hd_struct (partitions)
  '-' device

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


# LVM or RAID implementation


# FUSE (Filesystem in USEr space)

```
(fs/fuse/inode.c)
- module_init(fuse_init) =>
  - fuse_fs_init => register_filesystem(&fuse_fs_type)
```


# Reference

- LDD3
  - block device
- Understanding the Linux Kernel
  - VFS, Block layer, ext2/ext3
- https://ext4.wiki.kernel.org/index.php/Main_Page  
- https://git.kernel.org/pub/scm/fs/ext2/e2fsprogs.git
- http://www.rodsbooks.com/gdisk/index.html
- Documentation/filesystems
  - vfs.txt
  - path-lookup.txt, path-lookup.md
