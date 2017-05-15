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
  - https://khronos.org/registry/OpenGL/specs/gl/glspec45.core.pdf
  - mesa implementation
- wtf is "buffer api" ?
- drm, kms subsystem (mesa's drm wrapper)
  - drm-memory(7) (example dumb buffer creation)
  - does sway (wlc) do kms ?
  - when wayland server implementation use kms, then it's called drm backend. so wayland protocol itself doesn't have to
    mention drm or anything.
- intel gpu spec
  - ? i915
- ? libinput
- how does wayland expose egl platform ?
  - this is via mesa. and client can detect it on the fly somehow ?
  - mesa egl implementation uses wayland client code. (and wayland server implementation can support that path as long as it supports wayland protocol)
  - server implementation doesn't have to deal with


```
[ Data structure ]
display
surface (will be window when it's ?)
buffer (will be attached to surface)
sh_mem (buffer can based on this. server , which essentially is drm dumb buffer ?)

(how could client "draw" (fill data) to wl_buffer (since it's only an id for client ??))
- there's separate ipc going on between server and client (maybe that's wayland protocol drm extension ?)
- wayland protocol wl_shm_pool::create_buffer naturally supports drm memory and classic shared memory because
  it can specify location by offset within file.
  - cf. drm-memory(7) shm_overview(7)

mapping between egl, drm, and wayland interfaces
- EGLSurface creation -- wl_shm::create_pool, wl_shm_pool::create_buffer -- DRM_IOCTL_MODE_CREATE_DUMB
- GL drawing -- (essentially wayland doesn't have to care)
- eglSwapBuffers -- wl_surface::commit -- drmModeSetCrtc (and drmModePageFlip)

server vs client
- server drm
  - drmModeAddFB
  - drmModePageFlip
  - DRM_IOCTL_MODE_MAP_DUMB and memmap
- client drm (mesa's egl impl)
  - DRM_IOCTL_MODE_CREATE_DUMB ?

server (compositor) and client both does GL call but how are they different ?
- does wayland (or EGL) provide interface for both ? (i.e. is wayland-drm.c and egl/p)
  - wayland-drm.c
  - egl/drivers/dri2/platform_wayland.c

- create_wl_buffer (platform_wayland.c) =>
  - wl_create_buffer
```

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


# Wayland example

- client
  - weston-flower
  - weston-terminal
  - weston-info
  - egl app ?
- server
  - sway

```
$ weston-info
interface: 'wl_drm', version: 2, name: 1
interface: 'wl_compositor', version: 3, name: 2
interface: 'wl_shm', version: 1, name: 3
	formats: XRGB8888 ARGB8888
interface: 'wl_output', version: 2, name: 4
	x: 0, y: 0, scale: 1,
	physical_width: 290 mm, physical_height: 160 mm,
	make: 'BOE', model: '0x05df',
	subpixel_orientation: unknown, output_transform: normal,
	mode:
		width: 1366 px, height: 768 px, refresh: 59.973 Hz,
		flags: current preferred
interface: 'wl_data_device_manager', version: 3, name: 5
interface: 'gtk_primary_selection_device_manager', version: 1, name: 6
interface: 'zxdg_shell_v6', version: 1, name: 7
interface: 'wl_shell', version: 1, name: 8
interface: 'gtk_shell1', version: 1, name: 9
interface: 'wl_subcompositor', version: 1, name: 10
interface: 'zwp_pointer_gestures_v1', version: 1, name: 11
interface: 'zwp_tablet_manager_v2', version: 1, name: 12
interface: 'wl_seat', version: 5, name: 13
	name: seat0
	capabilities: pointer keyboard
	keyboard repeat rate: 33
	keyboard repeat delay: 500
interface: 'zwp_relative_pointer_manager_v1', version: 1, name: 14
interface: 'zwp_pointer_constraints_v1', version: 1, name: 15
interface: 'zxdg_exporter_v1', version: 1, name: 16
interface: 'zxdg_importer_v1', version: 1, name: 17
```  
