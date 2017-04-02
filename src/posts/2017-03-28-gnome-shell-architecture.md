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
          - gjs_register_native_module("gi", gjs_define_repo) (when is gjs_define_repo called ?)
          - gjs_register_static_modules => ?
        - (glib magic) gjs_context_constructed =>
          - gjs_runtime_ref => gjs_runtime_for_current_thread => JS_NewRuntime
          - JS_NewContext
          - JS::RootedObject global
          - gjs_init_context_standard =>
            - JS_InitStandardClasses
          - JS_DefineProperty(context, global, "window")
          - JS_DefineFunctions
          - gjs_create_root_importer and gjs_define_root_importer (assign "imports" as global's property)
  - meta_run => ?

(imports)
- JS_NewObject(gjs_importer_class)

(plugin setup/start (within meta_run ?)
- gnome_shell_plugin_class_init
- gnome_shell_plugin_start =>
  - _shell_global_set_plugin =>
    - shell_wm_new
    - (some branch by meta_is_wayland_compositor comes here too)
    - event callback setup (e.g. "after-paint", "notify::focus-window", etc...)
    - and more ...
  - gjs_context_eval("imports.ui.environment.init(); imports.ui.main.start();")

(import things)
- gjs_create_root_importer
  - gjs_create_importer => importer_new =>
    - JS_NewObject(...gjs_importer_class) ("GjsFileImporter" class instance, named "imports")

- "imports.gi" (native module) =>
  - importer_resolve (as JSResolveOp) => do_import =>
    - gjs_is_registered_native_module
    - import_native_file =>
      - gjs_import_native_module =>
        - gjs_define_repo => repo_new =>
          - gjs_get_import_global
          - JS_NewObject(...gjs_repo_class) (GIRepository)
      - JS_DefineProperty (assign "GIRepository" instance to "imports.gi")

- "imports.gi.Shell" (javascript) =>
  - repo_resolve =>
    - resolve_namespace_object =>
      - g_irepository_require
      - gjs_create_ns =>
        - gjs_ns_class => ns_new => JS_NewObject(...gjs_ns_class) (GIRepositoryNamespace)
      - JS_DefineProperty (assign "GIRepositoryNamespace" instance to "imports.gi.Shell")

- "imports.gi.Shell.AppSytem" =>
  - ns_resolve =>
    - g_irepository_find_by_name (gobject instropection)
    - gjs_define_info =>
      - (I guess it's G_TYPE_OBJECT and G_TYPE_IS_INSTANTIATABLE)
      - gjs_define_object_class =>
        - gjs_init_class_dynamic =>
          - (where is gjs_object_instance_constructor ...?)
          - JS_NewObject(...gjs_object_instance_class) (prototype object "GObject_Object")
          - JS_NewFunction (class as function object, which will be "AppSystem" itself)
          - JS_DefineProperty (assign "AppSystem" to "imports.gi.Shell.AppSystem")
        - gjs_object_define_static_methods =>
          - g_object_info_get_class_struct and g_struct_info_get_method (gobject instropection)
          - gjs_define_function =>
            - function_new(GICallableInfo) =>
              - JS_NewObject(...gjs_function_class)
              - init_cached_function_data =>
                - g_function_info_prep_invoker(function->invoker) (setup for libffi use)
            - JS_DefineProperty (e.g. assign function object to "imports.gi.Shell.AppSystem.get_default")

- "imports.gi.Shell.AppSystem.get_default" =>
  - (via mozjs) =>
    - function_call (as JSNative op from JSClass gjs_function_class)
      - gjs_invoke_c_function =>
        - (for each argument)
          - g_callable_info_load_arg (GICallableInfo)
          - (branching by GjsParamType of argument info)
        - ffi_call (libffi)
        - ??? beast (marshall happens here ?)

- "imports.gi.Shell.AppSystem.get_default().lookup_app('emacs24.desktop')" => ?

- "imports.ui" (javascript directory) =>
  - importer_resolve (as JSResolveOp) => do_import =>
    - ? (as GjsFileImporter)

- "imports.ui.appFavorites" (javascript file) =>
  - importer_resolve (as JSResolveOp) => do_import =>
    - ?


[ gobject introspection ]

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

# JS Component Example (Dash)

```
(who does new Dash ?)
- Dash._init =>
  - Main.initializeDeferredWork(... this._redisplay)

- Dash._redisplay =>
  - _createAppItem
    - new AppDisplay.AppIcon
      - AppIcon._init
        - connect('clicked', ... this._onClicked))

- AppIcon._onClicked =>
  - activate =>
    - app.activate (or app.open_new_window) (anyway, see below)
    - Main.overview.hide

- app.activate =>
  - (c impl) shell_app_activate => shell_app_activate_full =>
    - shell_app_activate_window =>
      - (metacity api a lot...)
      - meta_window_activate => ?

[concepts]
Actor
St, Layout
connect

ShellAppSystem
ShellApp (bindings between gobject and javascript)
Q. what does GIName:Shell.App mean in inspector ?

Q. how do imports.gi.Shell.AppSystem (js) and shell_app_system (c) bind together ?

Q. language bridges
imports (GijFileImporter) ok
imports.gi (GIRepository) ok
imports.gi.Shell (GIRepositoryNamespace) ? wtf
imports.gi.Shell.AppSystem (?) wtf

Q Javascript native binding
JS::MutableHandleObject::set(JSObject)
```

# TODO

- javascript thread
  - imports.mainloop ?
  - JSAutoRequest, JS_BeginRequest, JS_EndRequest
- native module injection
  - gjs ji modules
- js import mechanism (gjs api)
- gobject
  - static method and instance method (instropection finds existence of self ?)
- make function inspectable as object ?
- javascript class inheritance semantics
  - super and extends

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

# Shortcut for focusing favorite app

```
> imports.ui.appFavorites.getAppFavorites().getFavorites()
[app0, app1, ...]
> imports.ui.appFavorites.getAppFavorites().getFavoriteMap()['emacs24.desktop']
[object instance proxy GIName:Shell.App jsobj@0x... native@0x...]
```



# Reference

- Session 101: https://www.freedesktop.org/wiki/Software/systemd/multiseat/
- gobject 101: https://developer.gnome.org/gobject/stable/chapter-gobject.html#gobject-instantiation
- libffi: https://github.com/libffi/libffi/blob/master/doc/libffi.texi
