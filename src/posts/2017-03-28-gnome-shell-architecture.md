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
  - meta_plugin_manager_set_plugin_type(gnome_shell_plugin_get_type())
  - meta_init => ?
  - _shell_global_init => g_object_new_valist(SHELL_TYPE_GLOBAL) =>
    - (glib magic) shell_global_class_init
    - (glib magic) shell_global_init =>
      - g_object_new(GJS_TYPE_CONTEXT) =>
        - (glib magic) gjs_context_class_init
          - gjs_register_native_module (e.g. ) => ?
        - (glib magic) gjs_context_init
        - (glib magic) gjs_context_constructed =>
          - JS_NewContext
          - JS::RootedObject global
          - gjs_init_context_standard =>
            - JS_InitStandardClasses
          - JS_DefineProperty(context, global, "window")
          - JS_DefineFunctions
          - gjs_create_root_importer and gjs_define_root_importer (assign "imports" as global's property)
  - meta_run => ?

(maybe it's from meta_run ?)
- gnome_shell_plugin_class_init
- gnome_shell_plugin_start =>
  - _shell_global_set_plugin =>
    - shell_wm_new
    - (some branch by meta_is_wayland_compositor comes here too)
    - event callback setup (e.g. "after-paint", "notify::focus-window", etc...)
    - and more ...
  - gjs_context_eval("imports.ui.environment.init(); imports.ui.main.start();")


[ JS sources ]
- environment.init (js/ui/environment)
- main.start (js/ui/main) =>
  - _initializeUI =>
    - new WindowManager
    - and more ...
  - _sessionUpdated =>
    - WindowManager.setCustomKeybindingHandler('panel-run-dialog', ..., openRunDialog)
      - Meta.keybindings_set_custom_handler => ? native impl
- main.openRunDialog (js/ui/main) =>
  - new RunDialog.RunDialog
    - _init => _internalCommands = { 'lg': ... Main.createLookingGlass().open() }
  - RunDialog.open (js/ui/runDialog.js)
- main.createLookingGlass =>
  - new LookingGlass.LookingGlass => _init =>
    - connect('activate', ... LookingGlass._evaluate)
- LoogingGlass._evaluate => eval !


[ data structure ]
ShellGlobal (the_object!)
MetaPlugin
GnomeShellPluginClass
ShellWM
ClutterBackend
GjsContext (let's not go further to the mozilla js interface)
  JSRuntime, JSContext
```

# TODO

- create extension which does Super+n triggering open n-th favorite app
- javascript thread
- native module injection
  - gjs ji modules
- js import mechanism (gjs api)

# Configuration

```
# Check current setting
$ gsettings list-schemas | grep wm
org.gnome.desktop.wm.keybindings
$ gsettings list-recursively org.gnome.desktop.wm.keybindings | grep dialog
org.gnome.desktop.wm.keybindings panel-run-dialog ['<Alt>F2']

# Add new keybinding
$ gsettings set org.gnome.desktop.wm.keybindings panel-run-dialog "['<Alt>F2', '<Super>0']"
```

# Reference

- "Session" 101: https://www.freedesktop.org/wiki/Software/systemd/multiseat/
- gobject 101: https://developer.gnome.org/gobject/stable/chapter-gobject.html#gobject-instantiation
