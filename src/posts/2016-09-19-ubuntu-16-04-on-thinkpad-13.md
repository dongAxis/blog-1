<!--
{
  "title": "Ubuntu 16.04 on ThinkPad 13",
  "date": "2016-09-19T20:25:47.000Z",
  "category": "",
  "tags": [
    "ubuntu"
  ],
  "draft": true
}
-->

# Procedure

- login to windows and restart with UEFI menu
  - disable secure boot
  - reorder boot order
- Power on with F12 and choose USB boot
- ppa refind-install from ubuntu live usb

# some stuffs

- switch capslock and ctrl with `gnome-tweak-tool`
  - make caps lock an additional ctrl
- enable VT-x for virtual box
  - https://en.wikipedia.org/wiki/X86_virtualization#Intel_virtualization_.28VT-x.29
  - http://www.howtogeek.com/213795/how-to-enable-intel-vt-x-in-your-computers-bios-or-uefi-firmware/
  - cat /proc/cpuinfo
  

# restore from display glitch

```
$ xrandr --screen 0
Screen 0: minimum 8 x 8, current 3926 x 1080, maximum 32767 x 32767
eDP1 connected primary 1366x768+0+0 (normal left inverted right x axis y axis) 293mm x 165mm
   1366x768      59.97*+
   1360x768      59.80    59.96  
   1280x720      60.00  
   1024x768      60.00  
   1024x576      60.00  
   960x540       60.00  
   800x600       60.32    56.25  
   864x486       60.00  
   640x480       59.94  
   720x405       60.00  
   680x384       60.00  
   640x360       60.00  
DP1 disconnected (normal left inverted right x axis y axis)
HDMI1 connected (normal left inverted right x axis y axis)
   2560x1080     60.00 +
   1920x1080     60.00    60.00    50.00    59.94    24.00    23.98  
   1920x1080i    60.00    50.00    59.94  
   1680x1050     59.88  
   1280x1024     75.02    60.02  
   1280x800      59.91  
   1152x864      75.00  
   1280x720      60.00    50.00    59.94  
   1024x768      75.08    60.00  
   800x600       75.00    60.32  
   720x576       50.00  
   720x576i      50.00  
   720x480       60.00    59.94  
   720x480i      60.00    59.94  
   640x480       75.00    60.00    59.94  
   720x400       70.08  
HDMI2 disconnected (normal left inverted right x axis y axis)
VIRTUAL1 disconnected (normal left inverted right x axis y axis)

$ xrandr --screen 0 -s 1366x768

$ xrandr
Screen 0: minimum 8 x 8, current 1366 x 768, maximum 32767 x 32767
eDP1 connected primary 1366x768+0+0 (normal left inverted right x axis y axis) 293mm x 165mm
   1366x768      59.97*+
   1360x768      59.80    59.96  
   1280x720      60.00  
   1024x768      60.00  
   1024x576      60.00  
   960x540       60.00  
   800x600       60.32    56.25  
   864x486       60.00  
   640x480       59.94  
   720x405       60.00  
   680x384       60.00  
   640x360       60.00  
DP1 disconnected (normal left inverted right x axis y axis)
HDMI1 connected (normal left inverted right x axis y axis)
   2560x1080     60.00 +
   1920x1080     60.00    60.00    50.00    59.94    24.00    23.98  
   1920x1080i    60.00    50.00    59.94  
   1680x1050     59.88  
   1280x1024     75.02    60.02  
   1280x800      59.91  
   1152x864      75.00  
   1280x720      60.00    50.00    59.94  
   1024x768      75.08    60.00  
   800x600       75.00    60.32  
   720x576       50.00  
   720x576i      50.00  
   720x480       60.00    59.94  
   720x480i      60.00    59.94  
   640x480       75.00    60.00    59.94  
   720x400       70.08  
HDMI2 disconnected (normal left inverted right x axis y axis)
VIRTUAL1 disconnected (normal left inverted right x axis y axis)

```

# Reference

- http://www.rodsbooks.com/refind/installing.html
- https://support.lenovo.com/jp/en/solutions/ht118360
- man  xrandr(1)