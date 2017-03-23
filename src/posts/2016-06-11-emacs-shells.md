<!--
{
  "title": "Emacs Shells",
  "date": "2016-06-11T17:25:29.000Z",
  "category": "",
  "tags": [
    "emacs"
  ],
  "draft": false
}
-->

There are three types of shells inside of Emacs.

- `M-x shell`
- `M-x eshell`
- `M-x term`

I normally use `M-x shell` because of following reasons:

- able to copy&paste as if it's normal emacs buffer
- able to control wrap/truncate line as if it's normal emacs buffer
- `helm-comint-input-ring` helps input old commands repeatedly


But, as it's widely known, `M-x shell` (and `M-x eshell`) are "dumb" terminal, so you cannot simply use pager cli (e.g. git log, less, man, htop).

So, I have to `M-x term` for those cases. I recently found there are two "sub-modes" inside of `M-x term`:

- `C-c C-j`: change to _term-line-mode_
- `C-c C-k`: change to _term-char-mode_

If you are in _term-line-mode_, each key stroke won't be sent to terminal, so basically you can navigate your cursor around whole buffer as if your in `M-x shell`.

### Reference

- [https://lists.gnu.org/archive/html/help-gnu-emacs/2009-09/msg00732.html](https://lists.gnu.org/archive/html/help-gnu-emacs/2009-09/msg00732.html)
- [https://www.gnu.org/software/emacs/manual/html_node/emacs/Term-Mode.html](https://www.gnu.org/software/emacs/manual/html_node/emacs/Term-Mode.html)