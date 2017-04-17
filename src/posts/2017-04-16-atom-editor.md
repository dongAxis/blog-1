<!--
{
  "title": "Atom Editor",
  "date": "2017-04-16T11:22:02+09:00",
  "category": "",
  "tags": ["editor", "source"],
  "draft": true
}
-->

# Build from source

```
$ mkdir -p _install
$ ./script/build --install $PWD/_install
$ ln -s $PWD/_install/bin/atom ~/.local/bin
$ atom .
```


# Development (Debugging renderer javascript)

```
$ mkdir -p $PWD/_install/dev
$ ATOM_DEV_RESOURCE_PATH=$PWD ATOM_HOME=$PWD/_install/dev/.atom atom -f --socket-path $PWD/_install/dev/atom.sock --dev --profile-startup .
```

Note:

- --profile-startup opens chromium devtools on startup and it helps injecting debugger anywhere you want.
- By specifing non-default --socket-path, you can create different instance of atom application with same version.


# Browser process entry

```
[ Browser process ]
- src/main-process/main.js => start.js =>
  - AtomApplication.open (atom-application.coffee) =>
    - if `net.connect(..socketPath)`` works, send current options to existing app,
    - otherwise, new AtomApplication and initialize. =>
      - constructor =>
        - new Config, FileRecoveryService, StorageFolder, AutoUpdateManager, CompositeDisposable
        - handleEvents => ?
      - initialize =>
        - new ApplicationMenu, AtomProtocolHandler
        - listenForArgumentsFromNewProcess (listen for next `net.connect( socketPath )`)
        - launch => openWithOptions => openPaths =>
          - new AtomWindow =>
            - new BrowserWindow
            - handleEvents => ?
            - BrowserWindow.loadURL(...static/index.html)

[ Render process (static/index.html, index.js) ]
- index.js window.onload => setupWindow =>
  - require('../src/compile-cache') =>
  - CompileCache.install => (patch `require.extensions` to be able to load .coffee file)
  - require("../src/initialize-application-window.coffee") =>
    - new AtomEnvironment =>
      - new Workspace =>
  - (initialize-application-window.coffee's exports function) =>
    - AtomEnvironment.prototype.initialize =>
      - Config.prototype.load
      - StyleManager.prototype.buildStylesElement =>
        - new StylesElement (extends HTMLElement and registered as <atom-style>)
      - document.head.appendChild <atom-style>
    - AtomEnvironment.prototype.startEditorWindow =>
      - (promise loadState and displayWindow) =>
        - PackageManager.prototype.loadPackages
        - document.body.appendChild @workspace.getElement
        - PackageManager.prototype.activate
        - loadUserKeymap
        - requireUserInitScript
        - openInitialEmptyEditorIfNecessary
      - ??        
```


# TODO

- editor architecture
  - syntax highlight
- extension architecture


# Questions

- what is custom path 'atom://about' ? is this chromium facility for custom url?


# Customization and Migration from VSCode

- open project (ctrl-r)
- open terminal (ctrl-\`)
- clang based c/c++ cross reference
- remove dock chevron
