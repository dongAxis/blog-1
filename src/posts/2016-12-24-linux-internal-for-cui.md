<!--
{
  "title": "Linux internal for CUI",
  "date": "2016-12-24T01:40:23.000Z",
  "category": "",
  "tags": [],
  "draft": false
}
-->

# Summery

- User space
  - systemd getty service
  - busybox getty
  - busybox login
- kernel
  - tty/vt subsystem in deep
  - fb subsystem a bit
  - input subsystem a bit

---

- User space
    - systemd (pid1) (see http://0pointer.de/blog/projects/serial-console.html)
        - getty.target (see systemd.special(7))
        - getty@.service (with Restart=always)
        - ? how systemd spawns getty dynamically (I couldn't find corresponding code)
    - busybox/loginutils/getty.c
        - setsid (see setsid(2))
        - open tty (specified as an argument) as stdin/stdout/stderr
        - ioctl(TIOCSCTTY) (see tty_ioctl(4))
        - setup tty attributes
        - execve to login process
    - busybox/loginutils/login.c
        - no tty work here
        - call pam library and vfork-exec shell process if authenticated
        - what happens after shell exits depends on pid1. (for this case, since getty@.service has Restart=always, it goes back to getty.)
    - ? how tmux handles pseudo ttys
    - ? ssh client/server
    - ? shell
    - GUI terminal emulator (e.g. xterm)
        - pts(4) and simulate tty with GUI input/output.
- Kernel
    - Kconfig:
        - TTY (tty subsystem)
        - VT (virtual terminal (Ctrl-Alt-F1 things))
        - VT_CONSOLE (system console for single user mode)
    - initialization steps
        - start_kernel -> console_init -> (console_initcall) -> con_init
        - start_kernel -> rest_init -> kernel_thread(kernel_init, ...) -> kernel_init -> kernel_init_freeable -> do_basic_setup -> do_initcalls -> (fs_initcall) -> chr_dev_init -> tty_init -> vty_init
    - how many kinds of device files out there ? (device number and initialization step)
        - tty_init      
            - 5:0 - /dev/tty
            - 5:1 - /dev/console
        - vty_init
            - 4:0 - /dev/tty0
        - tty_register_driver(console_driver)
            - 4:1...63 - /dev/tty1...63
        - vty_init -> vcs_init
            - 7:0 - /dev/vcs
            - 7:1 - /dev/vcs1
            - 7:128 - /dev/vcsa
            - 7:129 - /dev/vcsa1
        - con_init
            - ? I think this is not something used for use space, so let's skip it?
            - not really, on ubuntu, `vt.handoff` changes fg_console. `fg_console = vt_handoff - 1;`
            - is tty/vt subsystem ready here already ?
        - ? /dev/ttyS0...31
    - vt switching (there're many entrypoint which you can find by grepping `set_console`)
        - ioctl (e.g. VT_ACTIVATE) -> set_console -> console_callback (vt.c) -> change_console (vt_ioctl.c) -> ... -> redraw_screen, wake_up_interruptible(&vt_event_waitqueue);
        - ? does "ctrl-alt-F1" corresponds to `k_cons` which is `*(k_handler[5])(...)`
    - drivers/vt/keyboard.c
        - initialization: kbd_init -> input_register_handler(&kbd_handler) -> kbd_connect -> ...
        - event handling: kbd_event -> kbd_keycode -> tty_insert_flip_char, tty_schedule_flip -> flush_to_ldisc (via workqueue)
        - process read operation:
            - tty_read => tty->ldisc->ops->read (which is n_tty_read) => copy_from_read_buf
            - how `tty->disc_data` and `tty->port->buf` relate each other 
                - `flush_to_ldisc` does it
        - how do you deal with hot-plugged keyboard (since it looks like `kbd_init` is only called at kernel initialization step) ?
            - I believe input subsystem's gonna apply registered handler to hotplugged keyboard too.
            - /proc/bus/input/{handlers,devices}
    - drivers/vt/vc_screen.c
        - process write operation:
            - tty_write => tty->ldisc->ops->write (which is n_tty_write) => tty->ops->write (which is con_write) => do_con_write (doing something big...)
        - who really draws "vc_data" physically ?
            - `struct con_driver` does it. Some display driver registers itself by calling `do_take_over_console`
                - corresponding kernel log is something like "Console: switching to colour frame buffer device 170x48"
                - on my PC, this happened three times around "efifb", "i915_bpo", and "fbcon: inteldrmfb (fb0)"
            - `do_con_write` calls device specific `vc->vc_sw->con_putcs`.
            - Documentation/fb/{framebuffer,efifb,intelfb,fbcon}.txt
            - fbcon (with drm) initialization steps: intel_fbdev_initial_config => drm_fb_helper_initial_config => register_framebuffer => fb_notifier_call_chain(FB_EVENT_FB_REGISTERED, &event) => fbcon_fb_registered => do_fbcon_takeover => do_take_over_console
    - relationships between `file_operations`, `tty_operations`, and `tty_ldisc_ops`
        - for write, `file_operations` calls `tty_ldisc_ops`, which calls `tty_operations`.
        - for read, `file_operations` calls `tty_ldisc_ops`. 
            - notice there's no `tty_operations` read.