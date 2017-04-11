<!--
{
  "title": "Emacs C source Navigation",
  "date": "2016-08-11T03:35:32.000Z",
  "category": "",
  "tags": [
    "emacs"
  ],
  "draft": false
}
-->

__[Update]__: Later on, I found [cscope](http://cscope.sourceforge.net/), which is easier to use out-of-box with [xcscope.el](https://github.com/dkogan/xcscope.el) on Emacs.

- Minimal navigation
  - `C-c s d`: cscope-find-global-definition
  - `C-c s u`: cscope-pop-mark
  - `C-c s c`: cscope-find-functions-calling-this-function
  - `C-c s t`:  cscope-find-this-text-string

---

---



Recently, I started to read some of C projects from the Internet, such as, Linux, glibc, musl, Qemu. Just a quick summery to note to myself.

- Generate `TAGS` file

```
$ find . -type f -iname "*.[chS]" | xargs etags --append
```

- Minimal navigation
  - `M-.`: find-tag
  - `C-u M-.`: go to next match of find-tag
  - `M-*`: pop back to the point before find-tag
  - `visit-tags-table`: add new `TAGS` file to `tags-file-name` and `tags-table-list`
  - `select-tags-table`: choose and set to `tags-file-name` from `tags-table-list`

# Notes

- I tried `etags-select-find-tag` from [_etags-select_](https://www.emacswiki.org/emacs/EtagsSelect), but it didn't work some cases (e.g. `net_device` does only shows `net_device_stats`).
- I tried `helm-etags-select` from  _helm-mode_, but completion search is too slow for navigating linux kernel source. So, I disabled it as below:

```prettyprint
(require 'helm-config)
(helm-mode)
(setcdr (assoc 'find-tag helm-completing-read-handlers-alist) nil) 
;;  see https://github.com/emacs-helm/helm/wiki#customize-helm-mode
```
  
# References

- http://courses.cs.washington.edu/courses/cse451/10au/tutorials/tutorial_ctags.html
- https://www.emacswiki.org/emacs/BuildTags
- https://www.gnu.org/software/emacs/manual/html_node/emacs/Select-Tags-Table.html