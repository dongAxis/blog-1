<!--
{
  "title": "Rescue Linux",
  "date": "2017-03-26T19:00:19+09:00",
  "category": "",
  "tags": ["linux", "systemd"],
  "draft": false
}
-->

On grub screen, you can edit kernel command line something like below:

```
# From
linux	/boot/vmlinuz-4.8.0-41-generic.efi.signed root=UUID=53fb1dc7-e008-4dfc-ae2c-ce8e8849992e ro  quiet splash $vt_handoff

# To
linux	/boot/vmlinuz-4.8.0-41-generic.efi.signed root=UUID=53fb1dc7-e008-4dfc-ae2c-ce8e8849992e ro systemd.unit=multi-user.target
```

As another way, if you choose a recovery mode `Ubuntu, with Linux 4.8.0-41-generic (recovery mode)`, you can still get a root shell.
One thing I stuck with is root file system is mounted with read-only mode, so in order to update some config file,
you have to do remount with normal mode by doing:

```
$ mount --bind / /
```

# Referemce

- systemd(1), init(1)
- systemd.special(7)
- mount(8)
- linux/Documentation/EDID/HOWTO.txt
  - mentions 'nomodeset'
