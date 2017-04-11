<!--
{
  "title": "Shell Job Control",
  "date": "2016-06-28T03:52:34.000Z",
  "category": "",
  "tags": [
    "shell"
  ],
  "draft": false
}
-->

Recently, I had to sync two AWS s3 buckets, which was the longest process I'd ever run on remote server. 
So, I needed to leave my process running with closing ssh connection. I looked for solution and that is `disown`, which seems very primitive functionality implemented in shell.
Here is a little demonstration about shell job control.

# Demo

```prettyprint
# I use "-axj" option to show PPID (parent process id), TT (terminal name) and STAT (state)
$ ps -axj | head -n1
USER              PID  PPID  PGID   SESS JOBC STAT   TT       TIME COMMAND

# start while loop process with output going to file
$ ruby -e 'puts "hello" while sleep 5' > out.log 2>&amp;1
^Z
[1]+  Stopped                 ruby -e 'puts "hello" while sleep 5' > out.log 2>&amp;1

# list jobs under current shell
$ jobs
[1]+  Stopped                 ruby -e 'puts "hello" while sleep 5' > out.log 2>&amp;1

# 'T' means it's stopped process
$ ps -axj | grep 'ruby -e'
hiogawa         53296 53061 53296      0    1 T    s000    0:00.04 ruby -e puts "hello" while sleep 5
hiogawa         53339 53061 53338      0    2 S+   s000    0:00.00 grep ruby -e

# disown doesn't work for 'Stopped' job
$ disown -h %1

# restart process background
$ bg %1
[1]+ ruby -e 'puts "hello" while sleep 5' > out.log 2>&amp;1 &amp;

# disown process from current shell
$ disown -h %1

# the job still shows up as a job
$ jobs
[1]+  Running                 ruby -e 'puts "hello" while sleep 5' > out.log 2>&amp;1 &amp;

# PPID/TT still doesn't change.
$ ps -axj | grep 'ruby -e'
hiogawa         53296 53061 53296      0    1 S    s000    0:00.04 ruby -e puts "hello" while sleep 5
hiogawa         53372 53061 53371      0    2 S+   s000    0:00.00 grep ruby -e

# only after current shell is killed, parent process will be 'init' process
$ exit

# here is ps output from another shell. note that PPID = 1 and TT = ??
$ ps -axj | grep 'ruby -e'
hiogawa         53296     1 53296      0    0 S      ??    0:00.04 ruby -e puts "hello" while sleep 5
hiogawa         53394 52817 53393      0    2 S+   s001    0:00.00 grep ruby -e
```

One thing worth mentioning:

- if you start process with terminal I/O (e.g. `ruby -e 'puts "hello" while sleep 5'` without output redirection), you cannot keep the process running after `exit`. All process using shell's terminal will be killed at the same time shell is killed.

# Further Tricks

- http://unix.stackexchange.com/questions/4034/how-can-i-disown-a-running-process-and-associate-it-to-a-new-screen-shell
- http://stackoverflow.com/questions/593724/redirect-stderr-stdout-of-a-process-after-its-been-started-using-command-lin

# Reference

- http://unix.stackexchange.com/questions/4004/how-can-i-close-a-terminal-without-killing-the-command-running-in-it
- http://stackoverflow.com/questions/625409/how-do-i-put-an-already-running-process-under-nohup
- http://superuser.com/questions/268230/how-can-i-resume-a-stopped-job-in-linux
- http://unix.stackexchange.com/questions/116959/there-are-stopped-jobs-on-bash-exit