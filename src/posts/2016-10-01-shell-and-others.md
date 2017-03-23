<!--
{
  "title": "Shell and others",
  "date": "2016-10-01T21:10:03.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

# Keywords

- Unix shell
  - sh, bash(1), zsh
  - https://en.wikipedia.org/wiki/Unix_shell
  - https://en.wikipedia.org/wiki/Comparison_of_command_shells
- Terminal emulater
  - xterm(1)
  - ssh(1), sshd(8)
- Terminal multiplexer
  - tmux(1)
  - screen
- Terminal
  - tty(4): /dev/tty*
  - controlling terminal (of a process)
  - tty(1): show current terminal
    - this normally shows like slave pseudoterminal.
- Pseudoterminal
  - pty(7)
  - ptmx(4), pts(4): /dev/ptmx, /dev/pts/*
    - pseudoterminal master and slave
  - devpts filesystem (mount(8))
- getty
  - agetty(8)
  - `/sbin/agetty --noclear tty1 linux` under `init` process

# good real example

- from init process to GUI login menu


init -> lightdm (as systemd service) -> lightdm -> upstart (user-mode)
                                                               -> xorg (with tty7)

- ssh, sshd 

# Questions 

- which process is handling login?
  - I feel user-mode upstart is run after login success.
  - unity-greeter or accounts-service
  - use `systemd-analyzer dot`
  - default -> graphical -> display-manager -> lightdm
                                                                           -> gpu
                                        -> accounts-daemon
- upstart(5)
- agetty
- gnome-keyring-daemon
- systemd-logind
- stdio(3)
- session?, process group, job
- kernel support (as an information in process descriptor?)
- virtual console: https://en.wikipedia.org/wiki/Virtual_console

# Diagram

---


ttys (virtual consoles, tty0~7) <-> ...
something? <-> tmux <-> terminal emulater <-> shell
                                               open ptms,pts

- http://0pointer.de/blog/projects/serial-console.html