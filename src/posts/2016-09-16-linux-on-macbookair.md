<!--
{
  "title": "Linux on MacBookAir",
  "date": "2016-09-16T17:51:31.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

# Flow

- clean install
  - recovery disk with `Cmd+R` booting
- 60GB partitions for OS X and Linux
- install refind from OS X with `./refind-install --notesp`
- create ubuntu liveusb stick with `dd ...`
  - http://osxdaily.com/2015/06/05/copy-iso-to-usb-drive-mac-os-x-command/
- install Linux into 60GB partition from liveusb
  - http://askubuntu.com/questions/453252/ubuntu-cant-detect-wifi-networks-on-macbookpro-13-3
  - https://itsfoss.com/fix-no-wireless-network-ubuntu/
- PROBLEM
  - by default, it boots with ubuntu
  - if booting with `alt`, I can select single drive and it boot os x
- go to osx and `./refind-install` again

# Problems

- close pc
- suspend
- webcam: 
  - https://github.com/patjak/bcwc_pcie/wiki/Get-Started#get-started-on-ubuntu
  - http://unix.stackexchange.com/questions/71064/automate-modprobe-command-at-boot-time-on-fedora
```
# /etc/modules-load.d/facetimehd.conf
facetimehd
```

# TODO

- configure rEFind and show only 2 options on boot menu
- turn on wifi device driver by default on ubuntu
  - copy .iso file with usb
  - mount .iso by https://itsfoss.com/fix-no-wireless-network-ubuntu/
  - check a different checkbox from the previous article to allow package manager to load package from cdrom
- Basic installation
  - keyboard shortcut
  - click, mouse speed
  - emacs, docker, git
  - browser

- install
 - fedora selinux: https://fedoraproject.org/wiki/SELinux/Understanding
 - arch linux: https://wiki.archlinux.org/index.php/Installation_guide
 - red hat server: http://developers.redhat.com/products/rhel/get-started/

# Wifi driver

??

# rEFInd configuration

??

# change brightness

- https://wiki.archlinux.org/index.php/Backlight
- install xbacklight and debug
- bunch of commands
  - lshw
  - lspci

# Acceralate pointer speed

- http://askubuntu.com/questions/172972/configure-mouse-speed-not-pointer-acceleration

```
$ xinput --list
⎡ Virtual core pointer                    	id=2	[master pointer  (3)]
⎜   ↳ Virtual core XTEST pointer              	id=4	[slave  pointer  (2)]
⎜   ↳ bcm5974                                 	id=11	[slave  pointer  (2)]
⎣ Virtual core keyboard                   	id=3	[master keyboard (2)]
    ↳ Virtual core XTEST keyboard             	id=5	[slave  keyboard (3)]
    ↳ Power Button                            	id=6	[slave  keyboard (3)]
    ↳ Video Bus                               	id=7	[slave  keyboard (3)]
    ↳ Power Button                            	id=8	[slave  keyboard (3)]
    ↳ Sleep Button                            	id=9	[slave  keyboard (3)]
    ↳ Apple Inc. Apple Internal Keyboard / Trackpad	id=10	[slave  keyboard (3)]

$ xinput --list-props 11
Device &#039;bcm5974&#039;:
	Device Enabled (139):	1
	Coordinate Transformation Matrix (141):	1.000000, 0.000000, 0.000000, 0.000000, 1.000000, 0.000000, 0.000000, 0.000000, 1.000000
	Device Accel Profile (271):	1
	Device Accel Constant Deceleration (272):	2.500000     &lt;-- decrease this value
	Device Accel Adaptive Deceleration (273):	1.000000
	Device Accel Velocity Scaling (274):	12.500000
        ...

$ xinput set-prop 11 272 1  # arguments are &lt;device-id&gt; &lt;property-id&gt; &lt;value&gt;
```

# Hide partitions icon from dock

- http://askubuntu.com/questions/195988/how-can-i-remove-launcher-drive-icons 

```
$ sudo blkid
/dev/sda1: LABEL=&quot;EFI&quot; UUID=&quot;67E3-17ED&quot; TYPE=&quot;vfat&quot; PARTLABEL=&quot;EFI System Partition&quot; PARTUUID=&quot;0ee69f59-8e6f-468e-a8b7-c725f399a351&quot;
/dev/sda2: UUID=&quot;cee5e61f-4891-35bd-a909-5a9a6739d04a&quot; LABEL=&quot;Mac&quot; TYPE=&quot;hfsplus&quot; PARTLABEL=&quot;Mac&quot; PARTUUID=&quot;b39ece42-1691-40c8-a173-0ba40febf0b5&quot;
/dev/sda3: UUID=&quot;3c1aacde-7229-38d6-8e29-1962d8c8c4d6&quot; LABEL=&quot;Recovery HD&quot; TYPE=&quot;hfsplus&quot; PARTLABEL=&quot;Recovery HD&quot; PARTUUID=&quot;84eac8e4-06dc-49ac-aa4a-3bf986257922&quot;
/dev/sda4: UUID=&quot;944ef339-6787-40c8-9371-353c1662b7f5&quot; TYPE=&quot;ext4&quot; PARTUUID=&quot;bae2efe7-7c58-4acd-a82b-1eb366613cfb&quot;
/dev/sda5: UUID=&quot;7b248a8b-1232-41f3-933a-047bd3053704&quot; TYPE=&quot;swap&quot; PARTUUID=&quot;90d1d39b-0420-446e-8c56-cee5cdbe7193&quot;

$ gsettings set com.canonical.Unity.Devices blacklist &quot;[&#039;cee5e61f-4891-35bd-a909-5a9a6739d04a-Mac&#039;, &#039;3c1aacde-7229-38d6-8e29-1962d8c8c4d6-Recovery HD&#039;]&quot;
```

# Wifi restart

```
$ sudo modprobe -r wl &amp;&amp; sudo modprobe wl
```

# bluetooth network from cli

ref: 

- http://askubuntu.com/questions/222419/bluetooth-pan-dun-on-ubuntu 
- http://blog.sumostyle.net/2009/11/ubuntu-tethering-via-bluetooth-pan/

```
$ ...
```

# Reference

- http://www.rodsbooks.com/refind/index.html
- http://askubuntu.com/questions/688632/dual-boot-mac-el-captain-along-with-ubuntu-14-04
- UEFI
  - https://wiki.archlinux.org/index.php/MacBook#OS_X_with_Arch_Linux
  - https://wiki.archlinux.org/index.php/Unified_Extensible_Firmware_Interface#Apple_Macs
  - https://wiki.archlinux.org/index.php/Arch_boot_process
  - https://help.ubuntu.com/community/UEFI
- mount loop device: http://man7.org/linux/man-pages/man8/mount.8.html#THE_LOOP DEVICE