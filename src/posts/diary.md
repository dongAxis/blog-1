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

- what's voltage ? how could it exist in the first place ?
    - electrical potential between two points, so how does it happen ?
    - ok, it's just fundamental nature then
        - https://en.wikipedia.org/wiki/Electromagnetismthis
        - https://en.wikipedia.org/wiki/Fundamental_interaction
    - btw, how is "stuff" electrically charged (for force to be exist) ?
    - elctric charge is just a fundamental conserved property of some subatomic particles, so don't question it ?
        - https://en.wikipedia.org/wiki/Electric_charge
    - V: work per electric charge cf.
        - force (kg*m/s^2)   (as F = mass*acceralation)
        - work  (kg*m^2/s^2) (as W = F*displacement) (energy's unit is work)
        - power (watt) (kg*m^2/s^3) (as P = V*(electriccharges)/second)
    - aka electric potential, aka how much there is a "tension" to drive electric charge
    - cf. magnetic field (force): results from moving electric charges and elementary particle's spin
    - how do we have voltage (in the sense of daily life) ?
        - a whole bunch of ways to convert other energy into electric power: https://en.wikipedia.org/wiki/Power_station
        - battery drives electric charges, possibly with rechargeable characteristics, possibly using chemical reaction
          (which in tern is driven by atom or molucule level electric (aka ion) interaction)
          cf  https://en.wikipedia.org/wiki/Electric_power

- some fundamental stuff
    - fundamental (elementary) particle: a particle whose substructure is unknown by definition
    - https://en.wikipedia.org/wiki/Elementary_particle
    - atom: nucleus, electron (via electromagnetic force)
    - nucleus: proton, neutron (via nuclear force (aka residual strong force))
    - proton, neutron: some quarks (via strong force)
    - molecule: atoms (via chemical bond ie covalent bond (isn't it still eletromagnetic force?) or electromagnetic force)
    - photon

- speaker/headphone/microphone thoery and implementation
    - dynamic loudspeaker: https://en.wikipedia.org/wiki/Loudspeaker#Driver_design:_dynamic_loudspeakers
        - analog audio signal change -(a)-> magnetic force change -(b)-> sound pressure
        - (a) electromagnetic induction (Maxwell's equations) (TODO)
        - (b) is this that simple ?
        - dynamic microphone is opposite of this (condenser microphone is different)
    - condenser (capacitor) microphone: https://en.wikipedia.org/wiki/Microphone#Condenser
        - sound pressure -(a)-> change in distance betw. capacitor plates -(b)-> capacitance C change -(c)-> voltage change
    - frequency characteristics consideration ?
    - what's special in headphone compared to speaker ? not really in terms of mechanism.
    - some kind of standard which determines the loudness (decibel response) for given voltage ?
        - I mean, people don't won't to change PC sound volume when they change headphone.
        - "Sensitivity": db measured at 1meter from speaker with 1 watt power
    - http://education.lenardaudio.com/en/05_speakers.html
    - http://education.lenardaudio.com/en/10_mics.html
    - example
        - speaker: ?
        - headphone: ?
        - recorder: https://www.zoom-na.com/products/field-video-recording/field-recording/zoom-h1-handy-recorder#specs


# 2017-09-05

- 3D audio
    - https://en.wikipedia.org/wiki/Dummy_head_recording#Technical
    - https://en.wikipedia.org/wiki/Head-related_transfer_function
    - https://en.wikipedia.org/wiki/Sound_localization
    - other sense: visual cue, skin feeling of sound wave
    - amplitude change (panning)
    - phase/timing change
    - frequency filter based on human head and ear geometry
    - directional characteristics of original sound source matters too
    - what about in the existence of reverbation ? can it help/affect localization a lot ?
        - but, naive reverb effect implementation doesn't consider HRTF (and could break implemented HRTF effect)

- voltage (work per electric charge), watt (work per second) familiar examples
    - Laptop: http://psref.lenovo.com/Product/ThinkPad_13 (my pc)
        - 45-watt AC adapter (so, if we give 100V, PC will charge 45/100 ampere of electric current to chrge battery?)
        - Battery 42Wh       (power * time = work, so can this be represented as mAh ??)
    - Smartphone: https://www.asus.com/Phone/ZenFone-2-Laser-ZE500KL/specifications/ (my smartphone)
        - Battery 2400 mAh
        - USB as charger (just using V_bus pin ?)
    - USB: http://www.usb.org/developers/docs/ (Section 11.4, Power Distribution)
        - V_bus pin: 5V DC
        - unit load: 150mA (then determines W = 0.75watt)
        - separated standard for battery charging ?
    - AC plug in Japan: 100V, 50Hz (my country)
    - what is amperer (electric current I) ?
        - P = V * Q / time = V * I
        - I = V / R
        - assume V is given (eg battery's characteristics), then W is determined by I and I is determined by R or something.
        - what really comes first ? I mean, when USB standard says "device only allowed to draw 150mA", how/who impose/implement that?
        - people call it "Realization" when talking about the way to realize certain physical value (eg amperer I)
          from other value (eg voltage V) via physical laws.
        - controlling/understanding that sort of physical nature is science and engineering.
    - amperer hour: the amount of electric charges it can move (not voltage (or tension to drive electric chargs))
        - 2400mAh means if there is electric current 240mA, it will last 10h (= 2400mAh/240mA)
        - it sounds weird to use this as battery's quality since if voltage is higher,
          that will result in more work overall, but that sounds physically wrong.
    - watt hour: the amount of "work" it can do
        - 42Wh means if it is suuplying 42W, it will last 1h.
        - it sounds weird to use this as battery's quality since depending on voltage and electric current,
          it result in the different amount of electric charges battery moves overall.
          No?, voltage and electric curent anyway inter relates each other, so it's fine.
    - anyway, battery has unwritten voltage characteristics, so you can calcualate mAh and Wh from one to another ?

- boot linux on raspberry pi 3 model b
    - https://github.com/raspberrypi/firmware
    - https://www.raspberrypi.org/documentation/hardware/raspberrypi/bootmodes/
        - OTP (One time programmable memory) (why do you mention about this if it's not programmable by user ?)
        - MSD (Mass storage device (as in USB class standard))
    - https://www.raspberrypi.org/documentation/configuration/config-txt/
    - https://www.raspberrypi.org/forums/viewtopic.php?f=2&t=3042
    - http://www.denx.de/wiki/view/DULG/UBoot
    - http://elinux.org/RPi_U-Boot
    - https://archlinuxarm.org/platforms/armv8/generic
    - https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-3
    - let's see if there's any sketchy arch package (just looking around /var/lib/pacman/local after extracted tar archive):
        - raspberrypi-bootloader (https://archlinuxarm.org/packages/any/raspberrypi-bootloader)
            - this is just raspberrypi's upstream firmware
        - uboot-raspberrypi (https://archlinuxarm.org/packages/aarch64/uboot-raspberrypi)
            - hell yeah!, this does `cp u-boot.bin ${pkgdir}/boot/kernel8.img`.
    - So, the story is something like this:
        - GPU boots
        - GPU probes filesystem in SD card to get firmware and load it
        - GPU also read config.txt and do some hardware setup
        - GPU triggeres booting ARM CPU boots with some other firmware
        - ARM firmware loads kernel8.img (which is supposed to be linux kernel but it actually is u-boot)
        - ARM CPU executes u-boot
        - execute boot.scr
        - load kernel

- human ear mechanics: https://en.wikipedia.org/wiki/Ear
- human voice mechanics: https://en.wikipedia.org/wiki/Ear


# Next time

- analog/digital circuit
  - fpga

- instrument mechanics
  - electric guitar
  - piano
  - saxophone

- qt lv2 plugin ui
    - QCustomPlot
