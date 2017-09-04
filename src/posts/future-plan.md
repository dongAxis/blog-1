<!--
{
  "title": "Future Plan",
  "date": "2017-09-01T08:37:51+09:00",
  "special": true
}
-->

# near future

- video + audio data format: streaming (capture and playback), opus
- boot archlinux in raspberry pi 3 model b
    - test on qemu
    - device tree
- audio effects
    - bit reduction
    - tap distortion
    - chorus
    - flanger
    - 3D https://en.wikipedia.org/wiki/Head-related_transfer_function
- Game engine architecture
  - source mod
  - Urho3d
  - unreal 4
- arm device (raspberry pi) kernel build
- Desktop environment architecture/implementation


# a bit long term plan

- booting (beforel loading kernel, x86_64, aarch64)
- USB bus, PCI bus (spec and driver implementation)
- GPU (Video card) architecture (intel one for now)
  - kms drm
  - opencl implementation
  - opengl implementation
- Audio card
  - physically, electorinally
  - speaker/headphone implementation
  - analog to digital, digital to analog converter
- cgoup, namespace implementation
- virtual machine
  - qemu
  - kvm
