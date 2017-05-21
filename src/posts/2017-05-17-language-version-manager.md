<!--
{
  "title": "Language Version Manager",
  "date": "2017-05-17T11:15:57+09:00",
  "category": "",
  "tags": ["ruby", "python", "go", "nodejs"],
  "draft": true
}
-->

# TODO

- ruby (rbenv)
- go (gvm)
- nodejs (nvm)
- python (pyenv)
- rust (rustup)


# rbenv

rvm's scripts look too huge for me. So I go with rbenv.

- Setup

```
$ export PATH="$HOME/.rbenv/bin:$PATH"
$ eval "$(rbenv init -)" # defines function rbenv
```

- Functions
  - rbenv: this is the only function loaded into your shell.

- Environment variables
  - PATH: `shims/*` and `bin/rbenv` is put in scope.

- Note
  - only POSIX-compliant part is the output of `rbenv init -`, which is cool.
  - thanks to this technique, all other script (e.g. `bin/rbenv`) can be specific-shell's script
    because those scripts are spawned (not sourced) via function `rbenv`.

```
- (function call) rbenv xxx =>
  - bin/rbenv xxx =>
    - (exec to) libexec/rbenv-xxx or plugins/rbenv-xxx
```


- shims wrapper (e.g. ruby, irb)

```
(shims/ruby)
export RBENV_ROOT="/home/hiogawa/.rbenv"
exec "/home/hiogawa/.rbenv/libexec/rbenv" exec "$program" "$@"

(libexec/rbenv)
RBENV_VERSION="$(rbenv-version-name)" # => read $PWD/.ruby-version or .rbenv/version file
RBENV_COMMAND="$1"
RBENV_COMMAND_PATH="$(rbenv-which "$RBENV_COMMAND")"
RBENV_BIN_PATH="${RBENV_COMMAND_PATH%/*}"
export PATH="${RBENV_BIN_PATH}:${PATH}"
exec -a "$RBENV_COMMAND" "$RBENV_COMMAND_PATH" "$@"
```

- ruby-build
  - configure and make (how do you deal with lib dependency (e.g. readlink openssl) ?)

- setup for native extension build ? (how do you link system library)
  - mkmf (default lookup system include and lib folder ?)


# nvm

- Setup

```
$ export NVM_DIR="$HOME/.nvm"
$ . "$NVM_DIR/nvm.sh"
```

- nvm.sh
  - 3000 lines of POSIX-compliant shell script.
  - define many functions named nvm_xxx (e.g. nvm, nvm_install, nvm_use)
  - each functions call each other (not as subshell)
  - it also runs "nvm_auto use" on load time as side effect.


```
(nvm ls-remote)
- nvm_remote_versions => ...

(nvm install)
- nvm_install_binary =>
  - nvm_download_artifact =>
    - nvm_download

(nvm use)
- NVM_VERSION_DIR="$(nvm_version_path "$VERSION")"
- export PATH="$(nvm_prepend_path "$PATH" "$NVM_VERSION_DIR/bin")"
```

- TODO:
  - the use of `npm config` (e.g. prefix). why do we need `npm config delete prefix` ?
  - (npm config delete prefix is not persisted) ?
