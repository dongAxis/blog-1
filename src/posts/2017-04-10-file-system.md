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
  - fuse/

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
  - vfs_kern_mount (returns struct vfsmount) =>
    - mount_fs (returns struct dentry *) =>
      - file_system_type.mount =>
  - do_add_mount => ?

[ open ]
SYSCALL_DEFINE3(open, ...) => do_sys_open => ?

[ read ]

[ write ]

[ getdents ]
```


# Block Subsystem

- partition table
  - mbr, gpt
  - fdisk ?
  - logical volume
- bio
- block device driver


# Btrfs

- on disk format
- follow read/write


# FUSE (Filesystem in USEr space)

```
(fs/fuse/inode.c)
- module_init(fuse_init) =>
  - fuse_fs_init => register_filesystem(&fuse_fs_type)
```


# Reference

- LDD3
  - block things ...
- https://btrfs.wiki.kernel.org/index.php/Main_Page
- http://www.rodsbooks.com/gdisk/index.html
