<!--
{
  "title": "Changing Linux Desktop",
  "date": "2017-03-25T13:02:42+09:00",
  "category": "",
  "tags": ["linux", "x11", "wayland", "gnome"],
  "draft": true
}
-->

# Current flow

- systemd (default.target => graphical.target => display-manager.service => lightdm.target)
- lightdm
  - spawns display server (e.g. Xorg)
  - spawns greeter (e.g. unity-greeter) (user can select DE (session) to login (e.g. unity or gnome))
  - spawns upstart (it manages processes for desktop session)
      - spawns gnome-session
      - spawns compiz (if it's unity mode)

```
- /usr/share/lightdm/lightdm.conf.d (can specify default session and greeter here)
  - 50-ubuntu.conf (user-session=ubuntu)
  - 50-unity-greeter.conf (greeter-session=unity-greeter)

- /usr/share/upstart/sessions/ (see man upstart(5))
  - gnome-session.conf
    - `start on started dbus and xsession SESSIONTYPE=gnome-session`
    - `exec gnome-session --session=$DESKTOP_SESSION`
    - $SESSIONTYPE and $DESKTOP_SESSION is passed by lightdm depending on what user selected on greeter.
  - unity7.conf (exec compiz)
    - `start on xsession SESSION=ubuntu and started unity-settings-daemon`
    - `exec compiz`

- /usr/share/gnome-session/sessions
  - gnome.session (RequiredComponents=gnome-shell;gnome-settings-daemon;)
  - gnome-classic.session
  - gnome-wayland.session
  - ubuntu.session

- /usr/share/xsessions (who uses this ? does greeter/lightdm look at this ?)
  - gnome-classic.desktop
  - gnome.desktop
  - openbox.desktop
  - ubuntu.desktop
```

# Issue

- why does "GNOME on wayland" fails after it's selected in unity-greeter ?
  - https://bugs.launchpad.net/ubuntu/+source/gnome-session/+bug/1632772


# Sub topics

- What's logind session about ?
  - setuid thing too


# References

- https://wiki.archlinux.org/index.php/wayland#Window_managers_and_desktop_shells
- https://wiki.archlinux.org/index.php/GNOME#Starting_GNOME
