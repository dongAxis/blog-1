<!--
{
  "title": "File system",
  "date": "2017-04-10T21:09:50+09:00",
  "category": "",
  "tags": ["linux"],
  "draft": true
}
-->

# TODO, Summery

- follow system calls (mount, open, read, write)
- file system module
- block device driver
- user space implementation (FUSE)
- can it work without `CONFIG_BLOCK` ?


# File system

```
[ Register file system ]
register_filesystem

[ syscall mount ]
- SYSCALL_DEFINE5(mount, ...) => do_mount => do_new_mount =>
  - vfs_kern_mount (returns struct vfsmount) =>
    - mount_fs (returns struct dentry *) =>
      - file_system_type.mount =>
  - do_add_mount => ?

[ syscall open ]
SYSCALL_DEFINE3(open, ...) => do_sys_open => ?

[ syscall read ]

[ syscall getdents ]

[ Data structure ]
```

# Block device subsystem

Later...

# Reference

- Linux source

```
- fs/
  - KConfig, Makefile
  - open.c, read_write.c, readdir.c (open, getdents)
  - namespace.c (mount)
  - super.c (mount_fs)
  - inode.c, dcache.c
  - filesystem.c (register_filesystem)
  - mount.h (struct mnt_namespace, mountpoint, mount)
  - ext4/

- block/
  - KConfig, Makefile

- include/linux/
  - fs.h (struct file_system_type, block_device, inode, super_block)
  - dcache.h (struct dentry, dentry_operations)
  - mount.h (struct vfsmount)
```
