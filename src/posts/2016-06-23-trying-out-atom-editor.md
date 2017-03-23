<!--
{
  "title": "Trying Out Atom Editor",
  "date": "2016-06-23T17:43:43.000Z",
  "category": "",
  "tags": [
    "emacs",
    "atom"
  ],
  "draft": false
}
-->

Since I left my school, I've never met a developer using Emacs in web development. To support other developers in pair programming or whatever occasion, I really feel I need to be prepared for non-Emacs environment.

I know it's unrealistic not to use Emacs completely, so first thing I do is to list essential Emacs features I'm relying on.

# Emacs Favorite Features

- (?) region selection/navigation
  - `C-@`: set-mark

- (?) emacs-shell:
  - `M-x shell`

- (?) run command from anywhere
  - `M-!`, `C-u M-!`

- (?) directory navigation:
  - dired, dired-tree, helm

- (?) ssh browser
  - tramp-mode

- (ok) tab, window
  - elscreen
  - `C-x 5 2`

- (ok) line truncate mode switch
  - toggle-truncate-lines

- (ok) self-documentation ecosystem:
  - `C-h k`, `C-h v`, `C-h f`

- (?) elisp execution:
  - `M-:`

- (ok) spell checker integration:
  - `M-$`: ispell-word

- (no) search file with buffer name
  - `C-x b`

- (?) frame spliting
  - load file
  - rotate position

# Atom Features

- new window
  - `cmd-shift-n`

- self documentation:
  - `cmd-shift-p`: search command by name
  - Settings-Keybindings page: search command by key or name (this doesn't cover everything)

- References:
  - http://flight-manual.atom.io/getting-started/sections/atom-basics/
  - http://flight-manual.atom.io/using-atom/sections/basic-customization/
  - http://sweetme.at/2014/03/10/atom-editor-cheat-sheet/

- Sometimes opening a file, Atom does not open in a new tab
  - https://github.com/atom/atom/issues/11243

- soft wrap
  - `Editor: Toggle Soft Wrap`

- change current mode
  - https://discuss.atom.io/t/add-ability-to-select-language-using-command-palette/1856
  - `C-Shift-L`

- change root directory on tree-view (not implemented)
  - https://discuss.atom.io/t/change-root-directory-in-tree-view/8584/4
  - https://discuss.atom.io/t/newbie-question-changing-working-directory/11635

- Reveal active file in sidebar: https://discuss.atom.io/t/reveal-file-in-sidebar/2365
  - `Tree View: Reveal Active File`