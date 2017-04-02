<!--
{
  "title": "Moving to KDE Plasma",
  "date": "2017-04-01T17:34:13+09:00",
  "category": "",
  "tags": ["kde", "source"],
  "draft": true
}
-->

# Customization

- gnome/compiz like keybindings
  - compositer zooming (KWin)
  - compositer opacity change (KWin)
  - invert window color (Desktop Behaviour (Desktop Effect))
  - application switcher (KWin)
  - window switcher (KWin)
  - grab window for move (KWin)
  - grab window for resize (KWin)
  - show desktop (KWin)
  - lock screen (ksmserver)
  - overview mode (called "Toggle present windows" in KWin)
  - snap window to right/left (KWin)
  - maxmize window (KWin)
  - screenshot
- Input
  - caps lock as control
  - key repeat speed: 50 repeats/s
  - key repeat delay: 200ms
- touch pad scrolling (just messing with X with my hunch)

  ```
  $ xinput --list | grep -i touchpad
  ⎜   ↳ ETPS/2 Elantech Touchpad                	id=12	[slave  pointer  (2)]
  $ xinput --list-props 12 | grep -i scroll
    Synaptics Scrolling Distance (280):	64, 64
    Synaptics Edge Scrolling (281):	1, 0, 0
    Synaptics Two-Finger Scrolling (282):	1, 1
    Synaptics Circular Scrolling (289):	0
    Synaptics Circular Scrolling Distance (290):	0.100007
    Synaptics Circular Scrolling Trigger (291):	0
  $ xinput --set-prop 12 280 -64 -64
  ```

# KDE Architecture (TODO)

Process tree:

- lightdm
  - lightdm
    - startkde
      - kwrapper5 ksmserver
- start_kdeinit
- kdeinit5
  - plasmashell
  - ksmserver
    - kwin_x11
  - kded [kdeinit5]
  - klauncher
  - kactivitymanagerd
  - krunner
    - terminal
    - chrome
    - ...
  - emacs24 (this is not under krunner ?)

- build system
- qt
- ksmserver
- KWin
- Plasma
- DBus configuration
- Extension
- scripting
- some daemons

- Ubuntu packges
  - plasma-desktop
  - plasma-framework
  - plasma-workspace
  - kwin

# Hacking KDE

- Inspecting IPC (DBus)

  ```
  $ qdbus | grep kde
  org.kde.klauncher5
  org.kde.Solid.PowerManagement
  org.kde.Solid.PowerManagement.PolicyAgent
  org.kde.StatusNotifierWatcher
  org.kde.kappmenu
  org.kde.kcookiejar5
  org.kde.kded5
  org.kde.keyboard
  org.kde.kaccess
  org.kde.ActivityManager
  org.kde.ksmserver
  org.kde.screensaver
  org.kde.kglobalaccel
  org.kde.krunner
  org.kde.KWin
  org.kde.kwin.Screenshot
  org.kde.kwalletd5
  org.kde.KScreen
  org.kde.baloo
  org.kde.StatusNotifierHost-2807
  org.kde.plasmashell
  org.kde.polkit-kde-authentication-agent-1
  org.kde.JobViewServer
  org.kde.kuiserver

  $ qdbus org.kde.plasmashell
  /
  /AudioOutputs
  /AudioOutputs/0
  /DataEngine
  /DataEngine/applicationjobs
  /DataEngine/applicationjobs/JobWatcher
  /MainApplication
  /PlasmaShell
  /Unity
  /org
  /org/freedesktop
  /org/freedesktop/Notifications
  /org/kde
  /org/kde/osdService
  /org/kde/plasmashell

  $ qdbus org.kde.plasmashell /PlasmaShell
  method void org.kde.PlasmaShell.evaluateScript(QString script)
  method void org.kde.PlasmaShell.loadKWinScriptInInteractiveConsole(QString script)
  method void org.kde.PlasmaShell.loadScriptInInteractiveConsole(QString script)
  method void org.kde.PlasmaShell.setDashboardShown(bool show)
  method void org.kde.PlasmaShell.showInteractiveConsole()
  method void org.kde.PlasmaShell.showInteractiveKWinConsole()
  method void org.kde.PlasmaShell.toggleActivityManager()
  method void org.kde.PlasmaShell.toggleDashboard()
  method QDBusVariant org.freedesktop.DBus.Properties.Get(QString interface_name, QString property_name)
  method QVariantMap org.freedesktop.DBus.Properties.GetAll(QString interface_name)
  signal void org.freedesktop.DBus.Properties.PropertiesChanged(QString interface_name, QVariantMap changed_properties, QStringList invalidated_properties)
  method void org.freedesktop.DBus.Properties.Set(QString interface_name, QString property_name, QDBusVariant value)
  method QString org.freedesktop.DBus.Introspectable.Introspect()
  method QString org.freedesktop.DBus.Peer.GetMachineId()
  method void org.freedesktop.DBus.Peer.Ping()

  $ qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.showInteractiveConsole

  $ qdbus org.kde.KWin /KWin org.kde.KWin.showDebugConsole
  ```

- Play in console

  ```
  function pp(obj) {
      print(obj);
      print(JSON.stringify(Object.keys(obj)));
  }

  // pp(this);
  // pp(this.desktops()[0]);
  // pp(this.activities()[0]);
  // pp(this.panels()[0]);

  // this.panels()[0].widgets().forEach(pp);
  // this.panels()[0].widgets().forEach(function(w) { print(w.type) });
  pp(this.panels()[0].widgets()[0]);
  print(this.panels()[0].widgets()[0].index);
  print(this.panels()[0].widgets()[0].version);
  print(this.panels()[0].widgets()[0].id);
  print(this.panels()[0].widgets()[0].configKeys);
  print(this.panels()[0].widgets()[0].configGroups);
  print(this.panels()[0].widgets()[0].globalConfigGroups);
  print(this.panels()[0].widgets()[0].currentConfigGroups);
  print(this.panels()[0].widgets()[0].showConfigurationInterface());
  print(this.panels()[0].widgets()[0].readConfig('favorites'));
  print(this.panels()[0].widgets()[0].readConfig('systemApplications'));
  print(this.panels()[0].widgets()[0].readGlobalConfig('Shortcuts'));
  ```

- Explore source

```
[ plasma-desktop/runners]
- pasma-desktop/plasma-desktop-runner.cpp
  - PlasmaDesktopRunner::PlasmaDesktopRunner (krunner query "wm console" and "desktop console" is handled here)

[ plasma-workspace/shell]
- dbus/org.kde.PlasmaShell.xml (dbus interface spec)
- shellcorona.cpp
  - ShellCorona::showInteractiveConsole

[ application management]
- dbus org.freedesktop.Application Activate
```

- Building

```
# ~/.kdesrc-buildrc
# Autogenerated by kdesrc-build-setup. You may modify this file if desired.
global

    # This option is used to switch development tracks for many modules at
    # once. 'kf5-qt5' is the latest KF5 and Qt5-based software.
    branch-group kf5-qt5

    # The path to your Qt installation.
#   qtdir      ~/repositories/others/kde/qt5
    qtdir /usr # If system Qt

    # Install directory for KDE software
    kdedir     ~/repositories/others/kde/install

    # Directory for downloaded source code
    source-dir ~/repositories/others/kde/src

    # Directory to build KDE into before installing
    # relative to source-dir by default
    build-dir build

    # Use multiple cores for building. Other options to GNU make may also be
    # set.
    make-options -j3

end global


# Refers to the kf5-workspace file included as part of kdesrc-build. The file
# is simply read-in at this point as if you'd typed it in yourself.
include ~/repositories/others/kde/src/kdesrc-build/kf5-workspace-build-include
```

```
$ kdesrc-build --rc-file=.kdesrc-buildrc --build-only kwindowsystem
```

# TODO

- Build
- javascript context/binding
- Quick focus/launch to docked apps

# Reference

- https://community.kde.org/Guidelines_and_HOWTOs/Build_from_source/OwnQt5
- https://community.kde.org/Guidelines_and_HOWTOs/Build_from_source
- man xinput(1)
