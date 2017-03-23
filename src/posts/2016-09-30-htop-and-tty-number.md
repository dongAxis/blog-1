<!--
{
  "title": "htop and tty number",
  "date": "2016-09-30T21:22:54.000Z",
  "category": "",
  "tags": [
    "tty"
  ],
  "draft": false
}
-->

Right now, I'm learning these concepts:

- tty
- pty
- terminal
- shell
- terminal emulater
- terminal multiplexer
- (and generally device driver/file)

Here is one notes I found on the way.

---

_htop(1)_ shows process's _tty_nr_, which is a part of data read from _/proc/[pid]/stat_. Its format is explained in _proc(5)_ and here is the part for _tty_nr_:

```
 (7) tty_nr  %d
      The  controlling terminal of the process.  (The
      minor device number is contained in the  combi‐
      nation  of  bits 31 to 20 and 7 to 0; the major
      device number is in bits 15 to 8.)
```

For example:

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/10/Screenshot-from-2016-10-01-15-28-08.png"><img src="http://wp.hiogawa.net/wp-content/uploads/2016/10/Screenshot-from-2016-10-01-15-28-08.png" alt="Screenshot from 2016-10-01 15-28-08" width="1020" height="387" class="alignnone size-full wp-image-1744" /></a>

```prettyprint
$ cat /proc/self/stat # this shows a bunch of information
8412 (cat) R 7434 8412 7434 34833 8412 4194304 ...

$ cat /proc/self/stat | awk &#039;{print $7}&#039; # the 7th number is tty_nr
34833

$ printf &#039;%x\n&#039; 34833 # this number is not understood as decimal, so convert it to hex
8811

$ printf &#039;%d\n&#039; 0x88 # the bits 8-15 represents major device number
136

$ printf &#039;%d\n&#039; 0x11 # the bits 0-7 represents minor device number
17

$ ls -l /dev/pts # such device file is found under /dev/pts
crw--w---- 1 hiogawa tty  136, 17 Oct  1 15:08 17
...

$ tty # of course, this coincides with the output of tty(1) 
/dev/pts/17
```

By the way, if you use ps(1), this number is already nicely printed:

```
$ ps aux | grep pts/17
hiogawa   8855  0.0  0.0  46984  3260 pts/17   R+   15:24   0:00 ps aux
...
```