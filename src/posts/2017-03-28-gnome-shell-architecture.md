<!--
{
  "title": "Gnome Shell Architecture",
  "date": "2017-03-28T20:04:18+09:00",
  "category": "",
  "tags": ["gnome", "gtk", "javascript", "source"],
  "draft": true
}
-->

```
[ Process hierarchy ]
- systemd (--system)
  - systemd (--user) (used since ubuntu 16.10 ?)
  - lightdm
    - Xorg
    - (greeter)
    - upstart
      - gnome-session-binary --session=gnome
        - gnome-shell

[ gnome-session-binary ]
- main => ?

[ gnome-shell (and metacity and clutter) ]
(main)
- main =>
  - meta_plugin_manager_set_plugin_type (gnome_shell_plugin_get_type ());
  - meta_init
  - meta_run => ?

(gnome-shell-plugin.c)
- gnome_shell_plugin_class_init
- gnome_shell_plugin_start =>
  - _shell_global_set_plugin =>
    - shell_wm_new
    - (some branch by meta_is_wayland_compositor comes here too)
    - event callback setup (e.g. "after-paint", "notify::focus-window", etc...)
    - and more ...
  - _shell_global_get_gjs_context => ?
  - gjs_context_eval("imports.ui.environment.init(); imports.ui.main.start();")

(gobject magic routine)
- shell_global_class_init
- shell_global_init =>
  - g_object_new(GJS_TYPE_CONTEXT) => ?
- gjs_context_class_init => ?
- gjs_context_constructed =>
  - global object initialization ?

  [ data structure ]
  MetaPlugin
  GnomeShellPluginClass
  ShellGlobal (most top level singleton, the_object!)
  ShellWM
  ClutterBackend
  GjsContext (let's not go further to the mozilla js interface)
    JSRuntime, JSContext


[ RunDialog and LookingGlass ]
- js/ui/main.js (_sessionUpdated)
- js/ui/runDialog.js (_internalCommands = { 'lg': ... })
- js/ui/lookingGlass.js (LookingGlass._evaluate)
- javascript binding (global object)
- javascript execution context (off main thread ?)
```

# TODO

- extension load mechanism
- looking glass architecture
- create extension which does Super+n triggering open n-th favorite app
- what is gnome-session (gnome-session-binary) for ?
  - relevancy to systemd's logind

# Reference

- "Session" 101: https://www.freedesktop.org/wiki/Software/systemd/multiseat/
- gobject 101: https://developer.gnome.org/gobject/stable/chapter-gobject.html#gobject-instantiation
