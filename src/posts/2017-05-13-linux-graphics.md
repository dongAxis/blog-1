<!--
{
  "title": "Linux Graphics",
  "date": "2017-05-10T13:49:57+09:00",
  "category": "",
  "tags": ["linux"],
  "draft": true
}
-->

# TODO

From top (wayland client) to bottom (kernel, gpu)

- wayland client
  - EGL client interface ?
- wayland server
  - https://wayland.freedesktop.org/docs/html/
  - https://wayland.freedesktop.org/building.html
  - ? what wayland expects EGL or kernel to do
- wayland
  - some EGL extension
- mesa
  - https://cgit.freedesktop.org/mesa/mesa/
  - https://cgit.freedesktop.org/mesa/drm/
- EGL (GL drawing surface interface e.g. eglSwapBuffers)
  - https://www.khronos.org/registry/EGL/
  - wayland implementation (as EGL's target platform)
  - mesa implementation (as client call)
- GL (GL drawing command interface)
  -
  - mesa implementation
- drm, kms subsystem
- intel gpu spec
  - i915


# Driver

```
$ lsmod | grep i915
i915                 1396736  32
drm_kms_helper        126976  1 i915
drm                   303104  7 i915,drm_kms_helper
intel_gtt              20480  1 i915
i2c_algo_bit           16384  1 i915
video                  36864  2 thinkpad_acpi,i915
button                 16384  1 i915
```
