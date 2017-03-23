<!--
{
  "title": "Transition from GitX to Magit",
  "date": "2016-09-09T21:35:41.000Z",
  "category": "",
  "tags": [
    "emacs",
    "git"
  ],
  "draft": false
}
-->

Here is a list of _GitX_ features I was depending on and corresponding _Magit_ way of doing that.

- See diffs for each file and stage/unsage/discard part of changes.
  - In magit-status buffer, pressing `tab` shows and hides a part of diffs. Then, with selecting a part of diffs by usual emacs region selection (e.g. `C-@`), you can state/unsage/discard respectively as below keys:
      - `s`: stage
      - `u`: unstage
      - `k`: discard
- Easy amending with previous commit.
  - Just `c a` from magit-status buffer.
- Show graphical history tree.
  - Just `l l` from magit-status buffer.
- Show conflict when rebasing
  - Conflict will naturally show up in magit-status buffer.

# References

- https://github.com/magit/magit/issues/649#issuecomment-39027936
- http://vickychijwani.me/magit-part-ii/