<!--
{
  "title": "Diary",
  "date": "2017-09-02T10:20:10+09:00",
  "special": true
}
-->

# 2017-09-01

- lxqt, openbox
    - it didn't feel good. lxqt-panel died for some search query. input customization didn't work (eg scroll opposite).
- dbus service activation
    - https://www.freedesktop.org/wiki/IntroductionToDBus/
    - it seems ladishd starts this way
- policy kit
    - https://www.freedesktop.org/software/polkit/docs/latest/
    - still confused the difference from pam
- build gnome shell with jhbuild
    - see examples in gtk+3 repo, I don't feel good about whole macro things.
      but, gnome shell is too good to use so I have to read the source.
- reverb
    - comb all pass filter: https://github.com/calf-studio-gear/calf/blob/master/src/calf/delay.h
    - magical parameters: https://github.com/calf-studio-gear/calf/blob/master/src/audio_fx.cpp#L258
- audio 101
    - http://education.lenardaudio.com/en/
    - speed of sound, wave length, reverberation


# 2017-09-02

- fdisk, partprobe, mkswap, swapon
    - partprobe
        - it uses ioctl BLKPG with operation BLKPG_ADD_PARTITION, BLKPG_DEL_PARTITION, BLKPG_RESIZE_PARTITION.
        - follow block/ioctl.c, partition-generic.c .. (TODO)
        - usually this process is done when loading block device driver ?
    - mkswap: setup some special header to the partition (or file)
    - swapon: calls SYSCALL_DEFINE2(swapon ..) (mm/swapfile.c)
- audio visualization in polyphone
    - https://aur.archlinux.org/packages/polyphone/ (follow original tar archive link from there)
    - time domain (graphique.cpp): ui is cool (drag, zoom ui), QCustomPlot
    - frequency domain (graphiquefourier.cpp, sound.cpp):
        - only use (samplerate / 2) of samples around loop area
        - correlation (for each wave length l, calculate \\sum_{i \\in (certain range)}|x(t + i) - x(t + i + l)|)
        - FFT (tomorrow)
- midi spec
    - pitch standard, A440
    - scientific pitch notation, C4
    - note event and frequency:
        - 69 = 0x45 = A4 = 440hz
        - 60 = 0x3C = C4 = (440 * (2 ^ (- 9 / 12))) = 261.63hz
        - n = 440 * (2 ^ (n - 69) / 12) hz
    - general midi, percussion note layout
- midi note key range (2nd byte, 7 bits)

```
      decimal  |  0    12  21             60   69                      120 127
          hex  |  00   0c  15             3C   45                      78  7f
  Hz (in A440) |              33  65  131 262  440  523 1047 2097 4186
pitch notation |  C-1  C0     C1  C2  C3  C4        C5  C6   C7   C8   C9     C10
               |           A0       E2  E3     A4      A5  E6              G9
               |
               |           <---- piano 88 keys (12 * 7 + 4) ------>
               |                    <------- guitar -------->
               |                        <--- alt sax --->
```


# 2017-09-03

- Fast Fourier Transform
  - cf. discrete fourier transform, (complex) fourier series, (generalized) fourier series, complete (bi)orthogonal system
  - https://en.wikipedia.org/wiki/Fast_Fourier_transform
  - http://mathworld.wolfram.com/FourierTransform.html
  - TODO: how does phase change appear in fourier transformed form ?
  - TODO: proof of cos(nx) and sin(nx) being complete biorthognal system (biorthognality is trivial)
  - TODO: practical factors (sample rate, human perceivable sound fequency range)
  - TODO: DFT by yourself
