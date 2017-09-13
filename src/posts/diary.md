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
    - brain compensates overall perception those small things even though we are not trying to perceive that factor "intentionally".
    - just like, without our intention, diff betw. two images from eyes are used by brain
      to make us understand the depth part of object's location.
        - https://en.wikipedia.org/wiki/Stereopsis#Geometrical_basis
        - a lot more factor than I thought https://en.wikipedia.org/wiki/Depth_perception
        - some of them must be also used for sound perception
            - eg "Familiar size": if huge-track-driving like sound's amplitude is small, human would feel that effect as distance of track
        - so, in computer graphics or AI, we need to implement such "brain" to do that part of processing.
    - other sense: visual cue, skin feeling of sound wave
    - amplitude change (panning)
    - phase/timing change
    - frequency filter based on human head and ear geometry
    - directional characteristics of original sound source matters too
    - what about in the existence of reverbation ? can it help/affect localization a lot ?
        - but, naive reverb effect implementation doesn't consider HRTF (and could break implemented HRTF effect)
    - let's see how software openal driver is implemented. and try via blender.
    - so I wanna experiment putting an earplug on one of my ear and how I can (not) recognize sound localization.
    - http://education.lenardaudio.com/en/10_mics.html
        - high frequency: amplitude difference
        - low frequency: phase difference
    - sound energy loss is affected only for high frequency factor ??
        - inverse square low ?
        - https://en.wikipedia.org/wiki/Inverse-square_law#Sound_in_a_gas

- Sound
    - https://en.wikipedia.org/wiki/Sound
    - reference sound pressure

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


# 2017-09-06, 2017-09-07

- basic audio effects
    - reverb: [image](./assets/2017-09-05-reverb.md)
    - chorus: enhance 3D-ness (is this because our brain is deceived in that way ? cf. sound localization)
    - distortion:
        - crusher (bitreduction, samplereduction): does work for classical piano, sample reduction sounds magical, but saturator works more natural sometimes
        - saturator (tap_distorgion): doesn't work for classical piano sound but this is so good for rhodes
    - filter: freaking magical biquad formulas

- random idea: osc on web project
    - https://gitlab.com/hiogawa/osc-on-web
    - http to osc proxy
    - interface in browser
    - browser ui interface drove me crazy, but I think that standard is very solid. (I'm curious how gtk, qt guys deals with this).
    - werkzeug: looks good. code is easy to follow so far (around run_simple reloading mechanism, Request/Response interface)
        - wsgi architecture is exactly same as ruby rack, so no problem with that.
    - python liblo: cython compiles python into c, that's impressive but I don't feel that's good architecture.
    - osc protocol is transport layer independent
      I prefer much thinner layering around that, like SWIG (as used in tensorflow) ?
    - so now, I don't have to use jack keyboard to play with sound effect in coffee shop.

- explore percussive sound and effects on it (or timbre of percussive sound)
    - bass
    - snare
    - symbal

- synthesize basic sound
    - pad
    - string
    - picky string

- human ear mechanics: https://en.wikipedia.org/wiki/Ear

- qt
    - http://doc.qt.io/qt-4.8/designer-ui-file-format.html

- sound
    - https://www.digido.com/portfolio-item/level-practices-part-2/
    - https://en.wikipedia.org/wiki/Cross-correlation
    - https://en.wikipedia.org/wiki/Precedence_effect

- cxx
    - http://en.cppreference.com/w/cpp/language/destructor
        - members and base classes destructor will be called recursively
        - eg. QXXX -> QScopedPointer<QXXPrivate>

# 2017-09-09

- lv2ui plugin with qt5
  - ui and rt communication (as far as I can tell from jalv)

- ruby fiber

- browser javascript multi process concurrency primitives
  - sharedbuffer, atomic
  - it sounds like it's not really sharing a memory

- hdr
    - ? spec

# 2017-09-10

- amazing carla's architecture
  - qt app as separate process via pipe bridging

- systemd-coredump, sysctl corepattern,

```
$ coredumpctl gdb
           PID: 2942 (jalv)
           UID: 1000 (hiogawa)
           GID: 1000 (hiogawa)
        Signal: 11 (SEGV)
     Timestamp: Sun 2017-09-10 23:18:56 JST (9min ago)
  Command Line: jalv -s http://hiogawa.net/lv2plugins/some_analyzer
    Executable: /usr/bin/jalv
 Control Group: /user.slice/user-1000.slice/session-c1.scope
          Unit: session-c1.scope
         Slice: user-1000.slice
       Session: c1
     Owner UID: 1000 (hiogawa)
       Boot ID: 98da1e0c3f624b0c86a1ec659bbaef1a
    Machine ID: c6f78d94a873436a916fea9d5065cba9
      Hostname: hiogawa-arch2
       Storage: /var/lib/systemd/coredump/core.jalv.1000.98da1e0c3f624b0c86a1ec659bbaef1a.2942.1505053136000000.lz4
       Message: Process 2942 (jalv) of user 1000 dumped core.

                Stack trace of thread 2942:
                #0  0x00007f71e5bd4120 _ZNKSt13__atomic_baseIiE4loadESt12memory_order (libQt5Core.so.5)
                #1  0x00007f71e5be446d _ZN7QStringD4Ev (libQt5Core.so.5)
                #2  0x00007f71e5bc4f89 _ZN9QHashData11free_helperEPFvPNS_4NodeEE (libQt5Core.so.5)
                #3  0x00007f71e5bdb471 _ZZN12_GLOBAL__N_123Q_QGS_globalEngineCache13innerFunctionEvEN6HolderD2Ev (libQt5Core.so.5)
                #4  0x00007f71f1cb2488 __run_exit_handlers (libc.so.6)
                #5  0x00007f71f1cb24da exit (libc.so.6)
                #6  0x00007f71f1c9bf71 __libc_start_main (libc.so.6)
                #7  0x000055fc9ba4709a n/a (jalv)

                ... other threads ...

... gdb starts here ...
GNU gdb (GDB) 8.0.1
...
Core was generated by `jalv -s http://hiogawa.net/lv2plugins/some_analyzer'.
Program terminated with signal SIGSEGV, Segmentation fault.
#0  std::__atomic_base<int>::load (__m=std::memory_order_relaxed, this=0x7f71f01ff720) at /usr/include/c++/7.1.1/bits/atomic_base.h:396
396     /usr/include/c++/7.1.1/bits/atomic_base.h: No such file or directory.
[Current thread is 1 (Thread 0x7f71f32c3b80 (LWP 2942))]
(gdb) bt
#0  0x00007f0a60be8120 in std::__atomic_base<int>::load(std::memory_order) const (__m=std::memory_order_relaxed, this=0x7f0a622bb720)
    at /usr/include/c++/7.1.1/bits/atomic_base.h:396
#1  0x00007f0a60be8120 in QAtomicOps<int>::load<int>(std::atomic<int> const&) (_q_value=...)
    at ../../include/QtCore/../../src/corelib/arch/qatomic_cxx11.h:227
#2  0x00007f0a60be8120 in QBasicAtomicInteger<int>::load() const (this=0x7f0a622bb720)
    at ../../include/QtCore/../../src/corelib/thread/qbasicatomic.h:102
#3  0x00007f0a60be8120 in QtPrivate::RefCount::deref() (this=0x7f0a622bb720) at ../../include/QtCore/../../src/corelib/tools/qrefcount.h:66
#4  0x00007f0a60bf846d in QString::~QString() (this=0x5604a2d1b500, __in_chrg=<optimized out>)
    at ../../include/QtCore/../../src/corelib/tools/qstring.h:1084
#5  0x00007f0a60bf846d in QRegExpEngineKey::~QRegExpEngineKey() (this=<optimized out>, __in_chrg=<optimized out>) at tools/qregexp.cpp:873
#6  0x00007f0a60bf846d in QHashNode<QRegExpEngineKey, QCache<QRegExpEngineKey, QRegExpEngine>::Node>::~QHashNode() (this=<optimized out>, __in_chrg=<optimized out>) at ../../include/QtCore/../../src/corelib/tools/qhash.h:149
#7  0x00007f0a60bf846d in QHash<QRegExpEngineKey, QCache<QRegExpEngineKey, QRegExpEngine>::Node>::deleteNode2(QHashData::Node*) (node=0x5604a2d1b4f0)
    at ../../include/QtCore/../../src/corelib/tools/qhash.h:536
#8  0x00007f0a60bd8f89 in QHashData::free_helper(void (*)(QHashData::Node*)) (this=0x5604a2b9e880, node_delete=0x7f0a60bf8460 <QHash<QRegExpEngineKey, QCache<QRegExpEngineKey, QRegExpEngine>::Node>::deleteNode2(QHashData::Node*)>) at tools/qhash.cpp:595
#9  0x00007f0a60bef471 in QHash<QRegExpEngineKey, QCache<QRegExpEngineKey, QRegExpEngine>::Node>::freeData(QHashData*) (this=<synthetic pointer>, x=0x5604a2b9e880) at ../../include/QtCore/../../src/corelib/tools/qhash.h:576
#10 0x00007f0a60bef471 in QHash<QRegExpEngineKey, QCache<QRegExpEngineKey, QRegExpEngine>::Node>::~QHash() (this=<synthetic pointer>, __in_chrg=<optimized out>) at ../../include/QtCore/../../src/corelib/tools/qhash.h:254
#11 0x00007f0a60bef471 in QHash<QRegExpEngineKey, QCache<QRegExpEngineKey, QRegExpEngine>::Node>::operator=(QHash<QRegExpEngineKey, QCache<QRegExpEngineKey, QRegExpEngine>::Node>&&) (other=..., this=0x7f0a611c4ef0 <(anonymous namespace)::Q_QGS_globalEngineCache::innerFunction()::holder+16>)
    at ../../include/QtCore/../../src/corelib/tools/qhash.h:260
#12 0x00007f0a60bef471 in QHash<QRegExpEngineKey, QCache<QRegExpEngineKey, QRegExpEngine>::Node>::clear() (this=0x7f0a611c4ef0 <(anonymous namespace)::Q_QGS_globalEngineCache::innerFunction()::holder+16>) at ../../include/QtCore/../../src/corelib/tools/qhash.h:582
#13 0x00007f0a60bef471 in QCache<QRegExpEngineKey, QRegExpEngine>::clear() (this=0x7f0a611c4ee0 <(anonymous namespace)::Q_QGS_globalEngineCache::innerFunction()::holder>) at tools/qcache.h:125
#14 0x00007f0a60bef471 in QCache<QRegExpEngineKey, QRegExpEngine>::~QCache() (this=0x7f0a611c4ee0 <(anonymous namespace)::Q_QGS_globalEngineCache::innerFunction()::holder>, __in_chrg=<optimized out>) at tools/qcache.h:93
#15 0x00007f0a60bef471 in (anonymous namespace)::Q_QGS_globalEngineCache::Holder::~Holder() (this=0x7f0a611c4ee0 <(anonymous namespace)::Q_QGS_globalEngineCache::innerFunction()::holder>, __in_chrg=<optimized out>) at tools/qregexp.cpp:3817
#16 0x00007f0a6cc13488 in __run_exit_handlers () at /usr/lib/libc.so.6
#17 0x00007f0a6cc134da in  () at /usr/lib/libc.so.6
#18 0x00007f0a6cbfcf71 in __libc_start_main () at /usr/lib/libc.so.6
#19 0x00005604a1e8f09a in  ()
```

- is this related ? https://stackoverflow.com/questions/21363494/need-to-change-include-path-for-clang#26841599
- looks similar http://kde-bugs-dist.kde.narkive.com/l1qXUpya/frameworks-kio-bug-373779-new-qfiledialog-integration-causes-crashes-on-program-exit
- https://stackoverflow.com/questions/8667234/why-does-my-application-crash-sometimes-with-a-sigsegv-when-it-gets-closed
- try valgrind !

- then this happens on carla
  - similar? https://bugreports.qt.io/browse/QTBUG-59721


# 2017-09-11

- chorus
  - calf's system (aka multichorus_audio_module)
    - modules_mod.cpp,h, multichorus.cpp,h, audio_fx.cpp,h
    - multichorus_audio_module
    - dsp::multichorus<.. sine_multi_lfo<float, 8> .. filter_sum<biquad_d2, biquad_d2 > ..> left, right
    - here filter_sum<biquad_d2, biquad_d2 > is only for post filter so don't mind it
    - multichorus : chorus_base : modulation_effect (inheritance)
    - procedures
      - multichorus_audio_module::params_changed =>
        - chorus_base::set_rate, set_min_delay, set_mod_depth,
        - sine_multi_lfo::set_voices, set_overlap, vphase, phase (stereo phase is setup here)
        - left.post.f1.set_bp_rbj .. (setup 2 band pass filters for left and right (only for post process))
      - multichorus_audio_module::process =>
        - left and right process completely separately
        - multichorus::process =>
          - delay.put
          - for each "voices"
            - sine_multi_lfo::get_value =>
              - calculate lfo value from voice index and vphase and overlapness and all that..
            - calculate number of samples to delay using delay, modulatin depth and lfo value
            - add up output gotten by delay.get_interp
  - parameters (lfo frequency, delay, depth, voice, overlap)
  - lfo's phase (stereo phase (betw. left and right), voice phase (betw. sine_multi_lfos))
  - looks like comb filter is modulating (which is from delay parameter)
    - depth (by ms) is about the depth of modurating "delay"
  - overlap?
  - understanding in terms of human sound localization

- https://en.wikipedia.org/wiki/Electric_guitar
  - similar to dynamic microphone (ie opposite of dynamic speaker)

- timbre (aka tone color)
  - https://en.wikipedia.org/wiki/Timbre
  - identification of "instrument" ?
  - how does machine learning tackle this now ?
  - lol

    > the psychoacoustician's multidimensional waste-basket category for everything that cannot be labeled pitch or loudness


# 2017-09-12

- calf crusher
  - sample reduction
  - bit reduction
    - number of bits
    - mode (linear or logarithm)
    - anti-aliasing

- crusher_audio_module::process =>
  - samplereduction::process (stateful. support float number of samples by m*f >= m*round(f)+1)
  - bitreduction::process (stateless)
    - waveshape (anti alias, discretization (number of bits, log, linear mode))

- gtk (glib, gobject, gdk)
  - https://www.gtk.org/documentation.php
  - https://developer.gnome.org/gobject/stable/chapter-gtype.html
  - classic
      - https://developer.gnome.org/gtk3/stable/chap-drawing-model.html
      - https://developer.gnome.org/gtk3/stable/chap-input-handling.html
  - https://developer.gnome.org/gobject/stable/howto-gobject.html
      - I usually don't mind boilerplate, but this is a bit too much ...
        I'd use it if there's a tool to generate declaration header on build time.
        (gob is closer to it, but not nice enough ?)
        (vala can be used in that way ?)
  - how gtkmm is implemented (or other any oop language binding) ?
  - this is really cool: http://helgo.net/simon/introspection-tutorial/index.xhtml
  - https://www.dwheeler.com/secure-programs/Secure-Programs-HOWTO/index.html

- openal
  - http://openal.org/documentation/openal-1.1-specification.pdf
  - http://openal-soft.org/
  - http://sound.media.mit.edu/resources/KEMAR.html
  - context: context as in GL. oh, that means context is implicit argument for the most operation ..
  - one listener per context (attributes: position, velocity, orientation (at vector, up vector))
  - multiple sources (attributes: position, velocity, direction, cone, distance attenuation model, buffer, etc..)
  - openal context, device
      - (how is "device" different from backend ? read below.)
      - static struct BackendInfo PlaybackBackend, CaptureBackend;
      - static struct BackendInfo BackendList[] (eg jack, pulse, alsa, ..)
      - alcOpenDevice(devicename) =>
        - NOTE: devicename is only for application side naming and associated configuration (not about backend)
        - DO_INITCONFIG => alc_initconfig =>
          - ReadALConfig
          - aluInitMixer
          - filter BackendList by configuration "drivers" or env var "ALSOFT_DRIVERS"
          - ALCbackendFactory::init for each factory from BackendList until init successes
            - setup PlaybackBackend, CaptureBackend
            - NOTE: alcOpenDevice's argument devicename doesn't matter at all for the way choosing backend
            - eg. ALCalsaBackendFactory_init => alsa_load => (load libasound.so)
          - InitEffectFactoryMap
          - InitEffect
        - alloc ALCdevice
        - PlaybackBackend.createBackend =>
          - NEW_OBJ(backend, ALCplaybackAlsa)
          - ALCplaybackAlsa_Construct => ALCbackend_Construct ..
        - setup openal parameters (eg channel, format (aka sample-type), freq ..)
          - use value corresponding to given "devicename" if it exists
        - Backend.open => ALCplaybackAlsa_open => snd_pcm_open
      - alcCreateContext (from device) =>
        - UpdateDeviceParams =>
          - aluInitRenderer => hrtf, ambdec
          - V0(device->Backend,start) (ie ALCplaybackAlsa_start) =>
            - althrd_create(.. ALCplaybackAlsa_mixerProc) (SEE BELOW for what this does)
        - AllocateVoices => ALvoice, ALvoiceProps (what are these ?)
        - InitContext =>
          - setup defaut parameters (or attributes) of Context and Context->Listener
        - UpdateListenerProps => context->Listener->FreeList
      - alcMakeContextCurrent => ..
      - alGenSources => al_calloc(16, sizeof(ALsource)) ..
      - alSourcei(source, ..) (eg buffer, source position, velocity)=>
        - DO_UPDATEPROPS (macro UpdateSourceProps) =>
      - alSourcePlay => alSourcePlayv =>
        - AllocateVoices ..
  - processing thread: ALCplaybackAlsa_mixerProc (THIS IS MAIN PART) =>
    - loop until self->killNow
      - snd_pcm_start,
      - snd_pcm_avail_update,
      - if avail < device->UpdateSize (aka period size), snd_pcm_wait(self->pcmHandle, 1000)
      - snd_pcm_mmap_begin
      - aluMixData =>
        - for each context in device->ContextList
          - UpdateContextSources => for each voice, CalcSourceParams =>
            - CalcAttnSourceParams =>
              - distance, orientation attenuation ..
              - doppler pitch correction ..
              - CalcPanningAndFilters =>
                - some correction based on original sound data's format (channels)
                - GetHrtfCoeffs => calculate HRIR for given elevation, azimuth angles (TODO: FOLLOW THE DETAIL)
                - CalcDirectionCoeffs(.. coeffs[MAX_AMBI_COEFFS]) => .. What's this ?? (only for effect ?)
          - for each voice in ctx->Voices
            - MixSource(voice, source, device ..) =>
              - ALfloat \*SrcData = Device->SourceData
              - LoadSamples ..
              - voice->Resampler ..
              - DoFilters ..
              - if voice->Flags&VOICE_HAS_HRTF
                - MixHrtfBlendSamples, MixHrtfSamples (aka MixHrtf) => ApplyCoeffs (convolution with hrir)
          - apply effect V(state,process)(SamplesToDo, slot->WetBuffer, state->OutBuffer)
        - MixDirectHrtf => ? (what's the reason for this ?)
        - ApplyDistanceComp(.. device->NFCtrlData)
        - WriteXX(Buffer, OutBuffer ..)
      - snd_pcm_mmap_commit
  - extensions
    - AL_EXT_SOURCE_RADIUS
    - AL_EXT_STEREO_ANGLES (alhrtf example uses this)
    - ALC_EXT_EFX (Alc/effects)
  - capture: don't talk about it, means nothing much
  - example programs (use sdl only for audio file decoding (abviously NOT for sound playback wrapper))
  - consideration for speaker setup and headphone setup ? (ambdec compensates speaker position, angle via AmbiDecoder)
  - hrtf definition files (refers docs/hrtf.txt)
    - TODO: visualize frequency response of .mhr file data (just covolving with plain sine data of each frequency should work ?)
  - when exactly non backend processing thread (or any al api call) could block by proccessing thread
    - I think al api call won't be blocked by processing because processing thread use solid atomic operation and CAS to update
      its own copy of data to mix sound.
  - size of single processing block (ie least amount number of samples where sound is rendered with parameters unchanged)
  - btw, in arch, sdl_sound is linked to sdl, but openal-examples is linked to sdl2, so those example doesn't work.
    compile with SDL would make it work, but alffplay.cpp doesn't compile for SDL.
  - https://github.com/neXyon/audaspace
    - this has utility+alpha kinds of functionality
    - use openal to give audio source location effect
    - hrtf effect (as convolution) is impemented outside of openal
    - blender's intern/audaspace is c binding version audaspace ?
  - Urho3D also has cool 3d audio setup (with SDL backend), I like this. very clean oop.
    - https://github.com/urho3d/Urho3D/tree/master/Source/Urho3D/Audio
    - openal's has much more feature but I should've read urho3d first for starter.


- https://wiki.libsdl.org/CategoryAudio
  - this is so nostalgic for me.. my first audio application was playback wav file using sdl api.
    I've looked through independent thread callback based api implementation with pulse backend.
  - lol, it wasn't that long time ago https://github.com/hi-ogawa/sound-stack


# 2017-09-13

- extract raw audio from soundfont as wav file
  - at least, polyphone does read sf2
  - or maybe I want to read through fluidsynth (fluid_synth_sfload). or linuxsampler ?
  - 1. extract raw audio data which literally living in soundfont file
  - 2. extract all available sounds from sf2 (which includes pitch compensentated keys and modulation effect etc..)
  - oh, libgig might do that already ? yes, it does. try sf2extract, sf2dump.

- soundfont (fluidsynth)
  - fluid_settings_t, fluid_synth_t, fluid_audio_driver_t, fluid_sequencer_t
  - do they internally have separate thread for event loop ? (eg, schedule_noteon, fluid_event_timer, sequencer_callback)
      - it doesn't seem that important for our usage (eg. in calf)
  - from the usage in calf (as always)
    - there's a fluid_synth_write_float(fluid_synth_t* synth, ..) interface for realtime integration
  - pitch compensation (fluid_sample_t.origpitch to fluid_voice_t.key)
  - does polyphony playback do something special ? don't think so
  - follow standard rt use flow (as in calf)
    - new_fluid_settings => ..
    - new_fluid_synth =>
      - new_fluid_defsfloader => FLUID_NEW(fluid_sfloader_t)
      - synth->channel[i] = new_fluid_channel
      - synth->voice[i] = new_fluid_voice (as many as polyphony needs)
    - fluid_synth_sfload => fluid_sfloader_load (ie fluid_defsfloader_load) =>
      - new_fluid_defsfont => FLUID_NEW(fluid_defsfont_t)
      - fluid_defsfont_load =>
        - sfload_file =>
          - FLUID_NEW (SFData)
          - load_body => chunk, process_info, process_sdta, process_pdta (cf. rifftree from libgig (linuxsampler))
        - fluid_defsfont_load_sampledata
        - (internally migrate from SFData (SFSample, ..) to fluid_defsfont_t (fluid_defpreset_t, ..) ?)
        - fluid_sample_import_sfont, fluid_defsfont_add_sample
        - fluid_defpreset_import_sfont, fluid_defsfont_add_preset
      - FLUID_NEW(fluid_sfont_t)
    - fluid_sfont_t.iteration_next (ie fluid_defsfont_sfont_iteration_next) =>
      - preset->noteon = fluid_defpreset_preset_noteon
    - fluid_synth_sfont_select, fluid_synth_bank_select, fluid_synth_program_change, fluid_synth_set_preset
    - fluid_synth_noteon => fluid_synth_noteon_LOCAL => fluid_preset_noteon (ie fluid_defpreset_preset_noteon) =>
      - fluid_defpreset_noteon =>
        - if fluid_preset_zone_inside_range, fluid_preset_zone_get_inst, fluid_inst_get_zone, fluid_inst_zone_get_sample
        - if fluid_inst_zone_inside_range
          - fluid_synth_alloc_voice =>
            - fluid_voice_init =>
              - voice->chan, voice->key, voice->vel, voice->sample = sample
              - fluid_rvoice_reset, fluid_rvoice_eventhandler_push
            - fluid_voice_add_mod ..
          - fluid_voice_add_mod if any
          - fluid_synth_start_voice => fluid_voice_start =>
            - fluid_voice_calculate_runtime_synthesis_parameters => fluid_voice_update_param
    - select_preset_in_channel => ..
    - fluid_synth_write_float =>
      - if synth->cur >= synth->curmax
        - fluid_synth_render_blocks =>
          - fluid_rvoice_eventhandler_dispatch_all => (voice to rvoice ???)
          - fluid_sample_timer_process
          - fluid_synth_add_ticks
          - fluid_rvoice_mixer_render =>
            - fluid_render_loop_singlethread =>
              - for each fluid_rvoice_mixer_t.active_voices, fluid_mixer_buffers_render_one => fluid_rvoice_write =>
                - (MAIN SYNTHESIS)
                - asdr, filter, lfo, modulator
                - voice->dsp.phase_incr = ...
                  (NOTE: this compensates the pitch key difference of original sample wave key and midi note key)
                - fluid_rvoice_dsp_interpolate_none (or linear, 4th_order, 7th_order) =>
                  - fill up dsp_buf based on original sample and phase_incr for key compensation
            - fluid_rvoice_mixer_process_fx => ..
        - fluid_rvoice_mixer_get_bufs => \*left = mixer->buffers.left_buf, right

- swig
  - llvm uses it for python binding
  - it's so fun reading example_wrap.c from the tutorial example for python
  - http://www.swig.org/Doc3.0/SWIGDocumentation.html#Introduction_nn5

- clang
  - http://clang.llvm.org
  - go through design documents
      - http://clang.llvm.org/docs/DriverInternals.html (clang binary to tool chain calls)
      - http://clang.llvm.org/docs/IntroductionToTheClangAST.html quick intro of AST (visitor sounds familiar from v8 code base)
      - http://clang.llvm.org/docs/InternalsManual.html ??
  - codegen (mapping clang AST to LLVM IR)
      - I don't find much documentation on this, but is this step such obvious ??
      - class layout, template specialization etc ..?
  - sanitizers implementation: compile time, runtime ??


# Next time

- frequency characteristics of basic wave form
  - square
  - saw
  - triangle

- instrument mechanics
    - human voice
    - piano
    - saxophone

- basic audio effects
    - flanger