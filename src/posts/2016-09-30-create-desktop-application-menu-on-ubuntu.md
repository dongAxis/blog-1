<!--
{
  "title": "Create Desktop Application Menu on Ubuntu",
  "date": "2016-09-30T20:10:27.000Z",
  "category": "",
  "tags": [
    "ubuntu",
    "desktop"
  ],
  "draft": false
}
-->

Linux version of [Android Studio](https://developer.android.com/studio/index.html) is not distributed as a package (.deb file) and [its installation instruction](https://developer.android.com/studio/install.html) only says 

> To launch Android Studio, open a terminal, navigate to the android-studio/bin/ directory, and execute studio.sh.

So, I thought it's good occasion to create desktop application menu by myself for the first time.

I didn't know any mechanism about desktop application registration, but it wasn't hard even without googling. Here is my process:

- Guessed other application must have some config file for this mechanism
  - Ran `dpkg-query -L emacs24` and found `/usr/share/applications/emacs24.desktop`
- Searched for local man page include "desktop"
  - Found two pages looking nice: _xdg-desktop-menu_ and _desktop-file-install_
  - These man pages gave me a link to [.desktop file specification](http://www.freedesktop.org/wiki/Specifications/desktop-entry-spec/)
- Wrote _androind-studio.desktop_ as below: (I downloaded and extracted zip at _/home/hiogawa/repositories/downloads/path/_)

```
[Desktop Entry]
Name=Android Studio
GenericName=IDE for Android Application Development
Exec=/home/hiogawa/repositories/downloads/path/android-studio/bin/studio.sh
Icon=/home/hiogawa/repositories/downloads/path/android-studio/bin/studio.png
Type=Application
```

- Ran `sudo xdg-desktop-menu install android-studio.desktop` but it didn't work.
- Ran `sudo desktop-file-install android-studio.desktop` and it did work.

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/10/Screenshot-from-2016-10-01-14-08-40.png"><img src="http://wp.hiogawa.net/wp-content/uploads/2016/10/Screenshot-from-2016-10-01-14-08-40.png" alt="Screenshot from 2016-10-01 14-08-40" width="719" height="471" class="alignnone size-full wp-image-1726" /></a>

# Small talks

- I heard the syntax of systemd's unit file is inspired by xdg .desktop file: http://0pointer.de/blog/projects/systemd.html

- These two binary comes from different packages. Maybe _xdg-desktop-menu_ doesn't work for unity?

```
$ dpkg-query -S desktop-file-install
desktop-file-utils: /usr/share/man/man1/desktop-file-install.1.gz
desktop-file-utils: /usr/bin/desktop-file-install

$ dpkg-query -S xdg-desktop-menu 
xdg-utils: /usr/bin/xdg-desktop-menu
xdg-utils: /usr/share/man/man1/xdg-desktop-menu.1.gz
```

- https://www.freedesktop.org/wiki/Software/desktop-file-utils/
- https://www.freedesktop.org/wiki/Software/xdg-utils/