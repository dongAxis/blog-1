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
    - cf. complete (bi)orthogonal system, (complex) fourier series, (generalized) fourier series, discrete fourier transform
    - should study from fourier series http://mathworld.wolfram.com/FourierSeries.html
    - how does phase change appear in fourier transformed form ?
        - phase change is linear combination of same frequency, as in
          cos(x+a) = cos(x)cos(a) - sin(x)sin(a) (or e^{i(x+a)} = e^{ix} * e^{ia})
    - proof of cos(nx) and sin(nx) being complete biorthognal system (biorthognality is trivial) (TODO)
    - interpretation in real world (complex coefficient, minus frequency, sample rate, perceivable sound fequency range)
        - periodic L, upto coefficient N, sample rate r (it is L = N for any reference, but it helps understanding DFT better when explicitly having them separate)
        - X_n represents ((n / L) * r) frequency part of coefficient (seems not realy like this ..)
        - non-complex value input
            - X_n (complex fourier series's coefficients) can be represented as a_n, b_n (fourier series's coefficients)
        - how to interpret decibel ??
    - what's the "validity" of DFT ?
        - it's just a result of "mathematically correct derivation".
        - it "works practically" only because human perceives sound in frequency damain for whatever reason (or god made us in that way.)
        - does human perceives phase difference ? (eg, how about sin(x) vs ((sin(x) + cos(x)) / 2) ?)
        - shoot, actually, sqrt(2) / 2 * cos(x - pi/4) = 1 / 2 * (sin(x) + cos(x))
    - Cooley–Tukey FFT algorithm: https://en.wikipedia.org/wiki/Cooley%E2%80%93Tukey_FFT_algorithm

- lv2 ui plugin architecture
    - ex. jalv gtk host (suil), calf analyzer plugin
    - (rt -> ui)
        - (rt) suil_instance_port_event, jalv_emit_ui_events, jalv->plugin_events (control output, event output)
        - (ui) port_event callback
        - how does "port notification audio port" work (as in calf analyzer) ?
          jalv doesn't look handling it.
    - (ui -> rt)
        - (ui) changes control input port value via LV2UI_Write_Function
        - (rt) read port value as usual
    - does calf analyzer really follow this principles ?
        - calf uses instance-access extension (see methods around plugin_proxy_base (eg get_line_graph_iface ..))
        - follow gui_instantiate (lv2gui.cpp) and see how they renders stuff (see 2017-07-25-lv2.md)

- gtk
    - following calf line graph (calf_line_graph_class_init)
    - GTK_WIDGET_CLASS (vtables under this eg expose_event, button_press_event ..)
    - gtk_widget_queue_draw


# 2017-09-04

- implement fft
    - https://gitlab.com/hiogawa/fft
    - cmake: integrate git submodule, target_compile_options
    - setup googletest
    - in-place Cooley–Tukey FFT algorithm: https://en.wikipedia.org/wiki/Cooley%E2%80%93Tukey_FFT_algorithm
    - cf. [image0](./assets/2017-09-04-fft0.jpg), [image1](./assets/2017-09-04-fft1.jpg)


# Next time

- speaker/headphone/microphone mechanics and implementation
  - http://education.lenardaudio.com/en/05_speakers.html
  - http://education.lenardaudio.com/en/10_mics.html

- qt lv2 plugin ui
    - QCustomPlot

- 3D audio https://en.wikipedia.org/wiki/Head-related_transfer_function
