<!--
{
  "title": "Posix Shell and Terminal",
  "date": "2017-04-05T22:23:23+09:00",
  "category": "",
  "tags": ["posix", "shell", "tty"],
  "draft": true
}
-->

My understanding of terminal and shell after reading [POSIX.1-2008](http://pubs.opengroup.org/onlinepubs/9699919799/nframe.html).

Especially around:

- [Vol. 1, Chap 3: Definitions](http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap03.html)
- [V0l, 1, Chap 11: General Terminal Interface](http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap11.html)

# Definitions

- Concepts not specific to shell
  - terminal (def. A character special file that obeys the specifications of the general terminal interface.)
  - session
  - session leader
  - process group
  - process
  - controlling terminal
  - controlling process
  - connection (from process to terminal)

Hierarchical view:

```
session (created upon `setsid`)
'-' session leader
    (extends process)
    (will be called controlling process if it's establishing connection to the controlling terminal)
'-* process group (created upon `setpgid`) (a.k.a. job)
  '-' process group leader (extends process)
  '-* process
'?' controlling terminal (it's optional)

foreground process group (extends process group) (set upon `tcsetpgrp`)
background process group (extends process group)
```

- Shell
  - http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18
  - what it really is just a utility program for controlling concepts listed above interactively.
  - Ctrl-C kinds of signal handling is not what shell is supposed to handle for child processes.

- Terminal
  - input control: (11.1.5 Input Processing and Reading Data)
      - so, Kernel (or tty subsystem) is supposed to implement something like Ctrl-C to SIGINT signal logic.
  - output control:

- Things left to implementation
  - "The controlling terminal for a session is allocated by the session leader in an implementation-defined manner."
      - so, we have to look at `agetty` or `gnome-terminal` for example?


# Real World Example

which I have to read and understand.

- /dev/console
- /dev/tty(n)
- /dev/pts/(n)
- gnome-terminal
- zsh
- getty
- Xorg
- PID1


# Side Notes

- how to check controlling process group (forground job) ?
- PID1's stdin/stdout/stderr
- Seat
- Graphical session

# Reference

- http://pubs.opengroup.org/onlinepubs/9699919799/
