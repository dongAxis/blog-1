<!--
{
  "title": "Upgrade Ubuntu",
  "date": "2017-03-26T14:43:36+09:00",
  "category": "",
  "tags": ["linux", "ubuntu"],
  "draft": true
}
-->

Here is my routine when I came across something I don't know:

```
# Find some entry with "upgrade" from emacs manpage search
$ man 8 do-release-upgrade

# Just run it for no reason (I expected 16.10 or 17.04 but nothing happened.)
$ do-release-upgrade
Checking for a new Ubuntu release
No new release found

# Let's check which package provides this executable
$ dpkg-query -S $(type -P do-release-upgrade)
ubuntu-release-upgrader-core: /usr/bin/do-release-upgrade

# Show me some detail about that package
$ apt show ubuntu-release-upgrader-core
$ apt showsrc ubuntu-release-upgrader

# I believe the package has some configuration file
$ dpkg-query -L ubuntu-release-upgrader-core
/etc/update-manager/release-upgrades

# It sounds like it
$ cat /etc/update-manager/release-upgrades
...
Prompt=lts
$ (edit the line to `Prompt=normal`)

# By the way, is the executable binary or what ?
$ file $(type -P do-release-upgrade)
/usr/bin/do-release-upgrade: Python script, ASCII text executable
$ (read python a little bit and give up)

# Let's run do-release-upgrade again
$ do-release-upgrade
Checking for a new Ubuntu release
Get:1 Upgrade tool signature [836 B]
Get:2 Upgrade tool [1,265 kB]
Fetched 1,266 kB in 0s (0 B/s)
authenticate 'yakkety.tar.gz' against 'yakkety.tar.gz.gpg'
extracting 'yakkety.tar.gz'
[sudo] password for hiogawa:
... it takes over tty
... at some point, it prompts start upgrading.
... before that, you can check some detail about package's transition, which is something like this:
...  - No longer supported: libreadline6
...  - Remove: wine
...  - Remove (was auto installed): pulseaudio-module-x11
...  - Install: gcc-6
...  - Upgrade: awscli
```


# Reference

- do-release-upgrade(8)
- https://wiki.ubuntu.com/YakketyYak/ReleaseNotes
