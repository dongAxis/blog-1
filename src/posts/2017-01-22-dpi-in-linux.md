<!--
{
  "title": "DPI in Linux",
  "date": "2017-01-22T14:31:45.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

- Information from my PC

```
$ cat /var/log/Xorg.0.log
...
[     6.872] (--) intel(0): Output eDP1 using initial mode 1366x768 on pipe 0
[     6.872] (==) intel(0): TearFree disabled
[     6.872] (==) intel(0): DPI set to (96, 96)
...
[     6.902] (II) intel(0): switch to mode 1366x768@60.0 on eDP1 using pipe 0, position (0, 0), rotation normal, reflection none
[     6.902] (II) intel(0): Setting screen physical size to 361 x 203

$ xdpyinfo
...
screen #0:
  dimensions:    1366x768 pixels (361x203 millimeters)
  resolution:    96x96 dots per inch
...
```

- how many dots in one pixel?

```
- 1366x768 pixels (361x203 millimeters)
- 96x96 dots per inch (1 inch = 2.54 cm = 25.4 mm)

=&gt;

in 1 mm square, 

- (96 * 96) / (25.4 ^ 2) = 14.315571142011107 pixels
- (1366 * 768) / (361 * 203) = 14.28482856965714 dots
```

- DPI
  - https://en.wikipedia.org/wiki/Dots_per_inch
  - is DPI a spec of a digital screen (monitor) ?
    - yes, and you can also call it PPI.
    - but, there's no reason we have to map 1pixel in software world to 1 dot (pixel) on physical screen as we should do for HiDPI setup.
  - what (which layer) to be modified for HiDPI ? (https://wiki.archlinux.org/index.php/HiDPI)
    - (assume display server doesn't "render" by itself and clients do DRI or at least only send bitmap)
    - display server:
      - it only needs to talk to HiDPI screen (no application specific concern here).
    - clients:
      - applications
        - compositer
        - browser
        - gtk, qt
        - font
        - non-vector image
    - text mode console ?
  - what is HDMI, VGA, DVI kinds of standard ?

- ? corresponding source
  - kms
    - drm_connector
    - edid
  - X video driver