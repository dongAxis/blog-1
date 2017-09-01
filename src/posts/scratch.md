<!--
{
  "title": "Scratch",
  "date": "2017-09-01T08:37:51+09:00",
  "special": true
}
-->


# Sfz and Linuxsampler

- sfz in Linux sampler: http://linuxsampler.org/sfz/

- http://www.karoryfer.com/karoryfer-samples/wydawnictwa/bear-sax

```
- Programs/
  - 1-solo-mono.sfz (#include "legato/breath.sfz")
  - legato/
    - breath.sfz (sample=../Samples/noise_breath.wav)
- Samples/
  - noise_breath.wav
```

this example doesn't work in Linuxsampler because relative path in `sample=<path>`
is resolved from directory `Programs/legato` instead of `Programs`.

Sidenote. it seems `#include` is one of ARIA custom opcodes (non-standard).

Here is a script to fix up the sfz files to make it work on Linuxsampler.

```
$ for f in Programs/**/*.sfz ; do sed -i 's/sample=../sample=..\/../' $f ; done
```

However, even after this I couldn't hear sound from linuxsampler (or via Carla host).


- https://www.plogue.com/products/sforzando/

this sfz player comes with one sfz file called tablewrap2. this sfz uses some weird looking opcode:

```
sample=*com.Madbrain.TableWarp2
```

which obviously didn't work on linuxsampler.

btw, sforzando's exe file is extracted via wine.


- http://www.akaipro.com/products/ewi-series/ewi-usb

The official one (in a sense where I started to use sfz with Akai usb device) comes with a good set of sfz files.
But again, sample path definition is not something linuxsample can understand. here is relevant opcodes from
Akai/EWI USB/Programs/02. Brass/Trumpet Cup Mute.sfz:

```
<control>
  hint_ram_based=1
  default_path=$A/
..

<region>  offset=704  lovel=1  hivel=127  lokey=34  hikey=53  pitch_keycenter=53  amplitude=100  tune=0  loop_mode=loop_continuous  loop_start=155594 loop_end=282634  sample=53T1cmF3_0001102C.audio

```

which obviously end up in `.../$A/53T1cmF3_0001102C.audio` from linuxsampler perspective.

Ok, I found the mysterious `$A` is defined in `EWI USB.bank.xml` as:

```
<?xml version="1.0" ?>
<AriaBank id="1004" name="EWI USB Default Bank" vendor="Akai" product="EWI USB" version="0001" >

        <Define name="$A" value="$sample_dir"/>
        <!-- <Define name="$B" value="GUI/default.xml"/> -->
```

So, anyway, possible fix should be

```
$ for f in Programs/**/*.sfz ; do sed -i 's/default_path=$A/default_path=..\/..\/..\/Samples/' $f ; done
```

Then, of course, it still doesn't work because of brutally raw audio is used for xxx.audio file.
Here is an error message from linuxsampler.

```
Can't get sample info: File contains data in an unknown format.
```
