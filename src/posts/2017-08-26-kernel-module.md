<!--
{
  "title": "Kernel Module",
  "date": "2017-08-26T23:19:51+09:00",
  "category": "",
  "tags": [],
  "draft": true
}
-->


# TODO

- module (.ko) files dependencies (does Kconfig or Makefile pick up that ?)
- depmod
- device hotplugging (driver part, udev part)
  - manual kernel module loading vs automatic loading
  - bus driver -> kernel netlink -> udev daemon -> do what ?? (module loading ??)
- read https://wiki.archlinux.org/index.php/Udev  
- who defines alias for module (cf. modinfo snd-usb-audio) ?
  - kernel uevent netlink will include that and udev can find kernel module based on it.
  - /usr/lib/modules/<kernel-version>/modules.alias
  - MODULE_DEVICE_TABLE macro as in MODULE_DEVICE_TABLE(usb, usb_audio_ids) ??
  - file2alias.c ?? (build system hook ?)
- .ko file formats (eg .modinfo section ?)

```
[ Makefile ]
snd-usb-audio-objs := card.o  ..
snd-usbmidi-lib-objs := ..

obj-$(CONFIG_SND_USB_AUDIO) += snd-usb-audio.o snd-usbmidi-lib.o


[ card.c ]
static struct usb_device_id usb_audio_ids [] = {
#include "quirks-table.h"
    { .match_flags = (USB_DEVICE_ID_MATCH_INT_CLASS | USB_DEVICE_ID_MATCH_INT_SUBCLASS),
      .bInterfaceClass = USB_CLASS_AUDIO,
      .bInterfaceSubClass = USB_SUBCLASS_AUDIOCONTROL },
    { }						/* Terminating entry */
};
MODULE_DEVICE_TABLE(usb, usb_audio_ids);


[ file2alias.c ]
- do_usb_entry =>
  - (construct string like "usb:vNpNdNdcNdscNdpNicNiscNipNinN")
  - buf_printf(&mod->dev_table_buf, "MODULE_ALIAS(\"%s\");\n", alias);


[ depmod ]
TODO


[ modinfo ]
$ modinfo snd-usb-audio
filename:       /lib/modules/4.12.4-1-ARCH/kernel/sound/usb/snd-usb-audio.ko.gz
license:        GPL
description:    USB Audio
author:         Takashi Iwai <tiwai@suse.de>
alias:          usb:v*p*d*dc*dsc*dp*ic01isc01ip*in*      # interface class 0x01, interface subclass 0x01 (aka AudioControl)
alias:          usb:v0D8Cp0103d*dc*dsc*dp*ic*isc*ip*in*
alias:          usb:v*p*d*dc*dsc*dp*ic01isc03ip*in*      # interface class 0x01, interface subclass 0x03 (aka AudioStream)
...


[ netlink ]
TODO


[ udev ]
```
