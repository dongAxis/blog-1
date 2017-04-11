<!--
{
  "title": "Manual log analysis with emacs",
  "date": "2015-11-28T18:07:58.000Z",
  "category": "",
  "tags": [
    "emacs",
    "grep",
    "awk"
  ],
  "draft": false
}
-->

##### Try out text-processing commands interactively

1. Make new buffer with `switch-to-buffer (C-x b)` followed by arbitrary buffer name.
Refs:
 - http://stackoverflow.com/questions/10363982/how-can-i-open-a-temporary-buffer

2. Put a part of huge log files into the buffer by `M-1 M-!` with a shell command you like.
Refs:
 - http://unix.stackexchange.com/questions/47513/emacs-open-a-buffer-with-all-lines-between-lines-x-to-y-from-a-huge-file
 - http://www.gnu.org/software/emacs/manual/html_node/emacs/Single-Shell.html#index-shell_002dcommand-3827

3. Select a region in the buffer and try any commands on the region with `C-|` or `C-u C-|`.

##### Show streaming log
After you find out commands to process log, you can combine it with `tail -f` to show a log in a streaming way.

The good thing about `tail -f` is the command is not a pager command like `less`, so you can use it in emacs shell without trouble. Then, the new log will be shown in emacs buffer, which means you can the easily use previous technique like `C-|` or `C-u C-|` to process it interactively.


This is an example:

```
$ tail -n 100 -f log/development.log | awk -v skip=-1 '/GET.*(jpg|JPG|png|PNG|jpeg)/ { skip = 6 } skip-- >= 0 { next } 1'
```


##### Example explained: Awk, Grep and Sed

What I wanted to do with the previous example is cutting out image request from the whole log like this:

```
...
Started GET "/trip-planner/development/spot_photo/image/556960e169702d3e709c0700/thumb_9346382163_876b6cf2d6_o.jpg" for 127.0.0.1 at 2015-11-28 20:07:22 +0900
Processing by PagesController#home as JPEG
  Parameters: {"path"=>"trip-planner/development/spot_photo/image/556960e169702d3e709c0700/thumb_9346382163_876b6cf2d6_o"}
Redirected to https://trip-planner-production.s3.amazonaws.com/production/spot_photo/image/556960e169702d3e709c0700/thumb_9346382163_876b6cf2d6_o.jpg
Completed 302 Found in 47ms
...
```

Basically, `grep` cannot do this kind of **hiding** multiple lines after matching point as explained in [stackoverflow](http://serverfault.com/questions/284305/remove-2-lines-from-output-grep-match-regular-expression-plus-next-1.)
`grep`'s options like `-A` (after), `-B` (before) and `-C` (context) can be used only for **showing** some lines around matching point.

Actually, I don't understand how `awk` works yet. The `awk` command piped to `tail -f` in the previous example is just what I got from the same [stackoverflow answer](http://serverfault.com/questions/284305/remove-2-lines-from-output-grep-match-regular-expression-plus-next-1.).

```
awk -v skip=-1 '/GET.*(jpg|JPG|png|PNG|jpeg)/ { skip = 6 } skip-- >= 0 { next } 1'
```

I think I like the below way by `for` and `getline`.
```
awk '/GET.*(jpg|JPG|png|PNG|jpeg)/ { for (i=1; i <= 6; i++) { getline } } 1'
```

`sed` realizes the similar thing with more intuitive (reasonable) syntax by specifing a range to hide (`/<reg-exp0>/,/<reg-exp1>/`) and delete command `d`:
```
sed -e "/GET.*jpg/,/Completed^^/d"
```

##### References

- itail (emacs plugin): https://github.com/re5et/itail
- grep (short for "g/regular expression/p,"):
 - http://www.thegeekstuff.com/2009/03/15-practical-unix-grep-command-examples/
- awk (derived from the initials of the language's three developers: A. Aho, B. W. Kernighan and P. Weinberger.):
 - http://www.grymoire.com/Unix/Awk.html
 - http://www.catonmat.net/blog/ten-awk-tips-tricks-and-pitfalls/
 - http://blog.urfix.com/25-awk-commands-tricks/
- sed (short for special editor):
 - http://www.grymoire.com/Unix/Sed.html#uh-30
- piping `tail -f`
 - http://stackoverflow.com/questions/11469959/how-to-pipe-tail-f-into-awk
 - http://superuser.com/questions/742238/piping-tail-f-into-awk