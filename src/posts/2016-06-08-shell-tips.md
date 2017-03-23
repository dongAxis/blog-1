<!--
{
  "title": "Shell Tips",
  "date": "2016-06-08T09:38:06.000Z",
  "category": "",
  "tags": [
    "shell"
  ],
  "draft": false
}
-->

# _fork_ vs _exec_

- see `man fork` and `man execv`
- http://stackoverflow.com/questions/1653340/differences-between-exec-and-fork

- quote from `man execv`

```
DESCRIPTION
   The exec family of functions replaces the current process image with a new process
   image.
```

- quote from `man fork`

```
DESCRIPTION
   Fork() causes creation of a new process.  The new process (child process) is an
   exact copy of the calling process (parent process) except for the following:

       o   The child process has a unique process ID.

       o   The child process has a different parent process ID (i.e., the process ID
             of the parent process).

       o   The child process has its own copy of the parent&#039;s descriptors.  These
             descriptors reference the same underlying objects, so that, for instance,
             file pointers in file objects are shared between the child and the parent,
             so that an lseek(2) on a descriptor in the child process can affect a sub-
             sequent read or write by the parent.  This descriptor copying is also used
             by the shell to establish standard input and output for newly created pro-
             cesses as well as to set up pipes.

       o   The child processes resource utilizations are set to 0; see setrlimit(2).
```

---

# _ps aux_  and _ps -aux_

- http://unix.stackexchange.com/questions/106847/what-does-aux-mean-in-ps-aux

```
    -a      Display information about other users&#039; processes as well as your own.  This
             will skip any processes which do not have a controlling terminal, unless the
             -x option is also specified.
    -j      Print information associated with the following keywords: user, pid, ppid,
             pgid, sess, jobc, state, tt, time, and command.

    -l      Display information associated with the following keywords: uid, pid, ppid,
             flags, cpu, pri, nice, vsz=SZ, rss, wchan, state=S, paddr=ADDR, tty, time,
             and command=CMD.

    -v      Display information associated with the following keywords: pid, state,
             time, sl, re, pagein, vsz, rss, lim, tsiz, %cpu, %mem, and command.  The -v
             option implies the -m option.
```
---

# Loop in Bash

- _While_ loop: Repeat a command until it fails

```
$ while true; do (/bin/some-command || break); done;
```

- _For_ loop

```
$ for i in {0..99}; do (/bin/some-command || break); done;
```

- References
  - http://www.tutorialspoint.com/unix/unix-loop-control.htm
  - http://www.cyberciti.biz/faq/bash-for-loop/

---

# Sound/Popup Notification After Long Process's Done in Shell

In `~/.bash_profile`, define `my_alert`:

```
my_alert() {
    osascript -e &#039;display notification &quot;&quot; with title &quot;Your script is done!!&quot;&#039;
    while true
    do
        say -v Bells &quot;dong dong dong dong&quot;
        sleep 0.5
    done
}
```

Then, when you have to wait for long process (e.g. build docker image) to finish, you would do:

```
$ docker build -t some-image . ; my_alert
```

- Reference
  - http://stackoverflow.com/questions/3127977/how-to-make-the-hardware-beep-sound-in-mac-os-x-10-6
  - http://apple.stackexchange.com/questions/57412/how-can-i-trigger-a-notification-center-notification-from-an-applescript-or-shel