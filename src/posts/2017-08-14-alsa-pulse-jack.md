<!--
{
  "title": "Alsa, Pulse, Jack",
  "date": "2017-08-14T12:22:57+09:00",
  "category": "",
  "tags": [],
  "draft": false
}
-->

# Alsa

- concepts
  - card device (eg hw:0, hw:1)
  - pcm device (aka named interface (more than that ??)) (eg default, pulse, hw:PCH, hdmi:..)
  - ctl interface (aka mixer)
- user space configuration
  - /etc/asound.conf (eg pulse as pcm.default)
  - /usr/share/alsa/alsa.conf (eg pcm.null)
  - /usr/share/alsa/cards/HDA-Intel.conf (?)
  - /usr/share/alsa/init ??
- pulse's alsa PCM device emulation (aka alsa's pulse backend)
  - libasound_module_pcm_pulse.so and libasound_module_conf_pulse.so from alsa-plugins repo
- TODO:
  - ucm, topology ??
  - hw vs sw (hwparam vs swparam)
  - slave, master
  - switching headphone and speaker happens (just happens on hardware ?)
  - kernel interface (driver device file)
  - device enumeration (udev and some hard coded config file ?)

```
- aplay, arecord
  - -l => list card device
  - -L => list PCM device
  - -D => specify PCM device to use

- speaker-test
  - -D => PCM device

- amixer
  - -c => card number
  - -D => PCM device
```


# Pulseaudio

- configuration (/etc/pulse/..)
- concepts
  - sink, source (eg alsa card backend or jack port backend)
  - sink-input, source-output (audio application using pulse api (eg chromium, mpd))
      - each sink-input (source-output) can choose which sink (source) to use if there's more than one.
      - actually mpd is being sink-input via pulse's alsa PCM device emulation.
  - client (whatever application which has a connection to pulse daemon (eg gnome volume controller))
- alsa card backend (module-alsa-card)
- jack backend (module-jack-sink, module-jack-source)
- Tips
  - is it possible to change sink-input's target sink while sink-input is running ?
      - `move-sink-input <sink-input-index> <sink-index>` will do.
  - is it possible for pulse damon to release alsa card during runtime ?
      - `suspend-sink <alsa-card-sink-index>` will do.


# Jack

```
- alsa_in, alsa_out
  - -d => specifiy card device
```
