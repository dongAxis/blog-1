<!--
{
  "title": "EFI: Extensible Firmware Interface",
  "date": "2016-09-03T14:52:24.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

```prettyprint
$ sudo fdisk -l /dev/sda
Disk /dev/sda: 113 GiB, 121332826112 bytes, 236978176 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disklabel type: gpt
Disk identifier: 8067911E-467D-4A8B-B092-9671882394B4

Device         Start       End   Sectors   Size Type
/dev/sda1         40    409639    409600   200M EFI System
/dev/sda2     409640 117891335 117481696    56G Apple Core storage
/dev/sda3  117891336 119160871   1269536 619.9M Apple boot
/dev/sda4  119162880 216817663  97654784  46.6G Linux filesystem
/dev/sda5  216817664 224630783   7813120   3.7G Linux swap


$ df -h
Filesystem      Size  Used Avail Use% Mounted on
udev            1.9G     0  1.9G   0% /dev
tmpfs           390M  6.3M  383M   2% /run
/dev/sda4        46G   21G   24G  47% /
tmpfs           2.0G   12M  1.9G   1% /dev/shm
tmpfs           5.0M  4.0K  5.0M   1% /run/lock
tmpfs           2.0G     0  2.0G   0% /sys/fs/cgroup
/dev/sda1       197M   21M  177M  11% /boot/efi
tmpfs           390M   76K  390M   1% /run/user/1000

$ sudo efibootmgr --verbose
BootCurrent: 0080
Timeout: 5 seconds
BootOrder: 0080,0000
Boot0000* ubuntu	HD(1,GPT,0ee69f59-8e6f-468e-a8b7-c725f399a351,0x28,0x64000)/File(\EFI\ubuntu\shimx64.efi)
Boot0080* Mac OS X	HD(1,GPT,0ee69f59-8e6f-468e-a8b7-c725f399a351,0x28,0x64000)/File(\EFI\refind\refind_x64.efi)
Boot0081* Recovery OS	PciRoot(0x0)/Pci(0x1c,0x5)/Pci(0x0,0x0)/Sata(0,0,0)/HD(3,GPT,7c323cb4-ed92-4172-b639-ba1e91b6ca5e,0xe0ca0b8,0x135f20)/File(\com.apple.recovery.boot\boot.efi)
Boot0082* 	PciRoot(0x0)/Pci(0x1c,0x5)/Pci(0x0,0x0)/Sata(0,0,0)/HD(3,GPT,84eac8e4-06dc-49ac-aa4a-3bf986257922,0x706e108,0x135f20)
BootFFFF* 	PciRoot(0x0)/Pci(0x1c,0x5)/Pci(0x0,0x0)/Sata(0,0,0)/HD(2,GPT,69df8594-9de5-42d9-9b77-ed4e91adf7d4,0x64028,0xe066090)/File(\System\Library\CoreServices\boot.efi)

# TODO: let&#039;s try this and see if what happens
$  efibootmgr -o 0000,0080
```

Ideally

Mac OS X: /dev/sda2 - \System\Library\CoreServices\boot.efi
Ubuntu: /dev/sda1 - \EFI\ubuntu\grubx64.efi

```
$ sudo sgdisk -i 2 /dev/sda
Partition GUID code: 53746F72-6167-11AA-AA11-00306543ECAC (Apple Core Storage)
Partition unique GUID: B39ECE42-1691-40C8-A173-0BA40FEBF0B5
First sector: 409640 (at 200.0 MiB)
Last sector: 117891335 (at 56.2 GiB)
Partition size: 117481696 sectors (56.0 GiB)
Attribute flags: 0000000000000000
Partition name: &#039;Mac&#039;

$ sudo blkid 
/dev/sda1: LABEL=&quot;EFI&quot; UUID=&quot;67E3-17ED&quot; TYPE=&quot;vfat&quot; PARTLABEL=&quot;EFI System Partition&quot; PARTUUID=&quot;0ee69f59-8e6f-468e-a8b7-c725f399a351&quot;
/dev/sda2: UUID=&quot;cee5e61f-4891-35bd-a909-5a9a6739d04a&quot; LABEL=&quot;Mac&quot; TYPE=&quot;hfsplus&quot; PARTLABEL=&quot;Mac&quot; PARTUUID=&quot;b39ece42-1691-40c8-a173-0ba40febf0b5&quot;
/dev/sda3: UUID=&quot;3c1aacde-7229-38d6-8e29-1962d8c8c4d6&quot; LABEL=&quot;Recovery HD&quot; TYPE=&quot;hfsplus&quot; PARTLABEL=&quot;Recovery HD&quot; PARTUUID=&quot;84eac8e4-06dc-49ac-aa4a-3bf986257922&quot;
/dev/sda4: UUID=&quot;944ef339-6787-40c8-9371-353c1662b7f5&quot; TYPE=&quot;ext4&quot; PARTUUID=&quot;bae2efe7-7c58-4acd-a82b-1eb366613cfb&quot;
/dev/sda5: UUID=&quot;7b248a8b-1232-41f3-933a-047bd3053704&quot; TYPE=&quot;swap&quot; PARTUUID=&quot;90d1d39b-0420-446e-8c56-cee5cdbe7193&quot;
```

# Disable logical volume

- http://curtis.hovey.name

after `distill coreStorage revert /dev/disk1`

```
$ diskutil list
/dev/disk0
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                        *121.3 GB   disk0
   1:                        EFI EFI                     209.7 MB   disk0s1
   2:                  Apple_HFS Mac                     60.2 GB    disk0s2
   3:                  Apple_HFS Recovery HD             650.0 MB   disk0s3
   4:       Microsoft Basic Data                         50.0 GB    disk0s4
   5:                 Linux Swap                         4.0 GB     disk0s5
```

# References

- https://en.wikipedia.org/wiki/Unified_Extensible_Firmware_Interface
- http://www.rodsbooks.com/refind/index.html
- https://wiki.archlinux.org/index.php/MacBook
- https://github.com/rhinstaller/efibootmgr
- http://www.binarytides.com/linux-command-check-disk-partitions/
- http://www.cyberciti.biz/faq/linux-list-disk-partitions-command/