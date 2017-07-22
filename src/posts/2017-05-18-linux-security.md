<!--
{
  "title": "Linux Security",
  "date": "2017-05-18T12:28:03+09:00",
  "category": "",
  "tags": ["linux"],
  "draft": true
}
-->

# login (util-linux)

```
[ agetty: `/sbin/agetty --noclear tty1 linux` ]
- main =>
  - open_tty => ..
  - tcsetpgrp ..
  - char* username = get_logname =>
    - do_prompt => write_all(STDOUT_FILENO, "login: " ..)
    - read(STDIN_FILENO ..)
  - execv(options.login ..)


[ login: `/bin/login -- hiogawa`]
- main =>
  - struct login_context cxt ..
  - cxt.username = <argv>
  - init_loginpam =>
    - pam_start("login", cxt->username, &cxt->conv, &pamh) => ??
  - loginpam_auth =>
    - loginpam_get_username => pam_get_item(pamh, PAM_USER, &item)
    - pam_authenticate =>
      - .. misc_conv (from <security/pam_misc.h>) ??
  - loginpam_acct =>
    - pam_acct_mgmt(pamh, 0) => ??
  - cxt.pwd = get_passwd_entry(cxt.username ..) =>
    - getpwnam_r (pwd.h)
  - initgroups(cxt.username, pwd->pw_gid) (grp.h)
  - loginpam_session =>
    - pam_setcred(pamh, PAM_ESTABLISH_CRED) => ??
    - pam_open_session(pamh, 0) => ??
    - pam_setcred(pamh, PAM_REINITIALIZE_CRED) => ??
  - init_environ => setup HOME, USER, SHELL, TERM env var
  - fork_session =>
    - ioctl(0, TIOCNOTTY, NULL)
    - fork
    - (parent) wait(NULL)
    - (child)
      - setsid
      - ioctl(0, TIOCSCTTY, 1)
  - (child)
  - setuid(pwd->pw_uid)
  - chdir(pwd->pw_dir)
  - execvp(pwd->pw_shell ..) (e.g. /bin/bash)


[ pam ]

(pam_unix.so)
auth
account
session
password

(pam_limits.so)
- setrlimit .. (this only persists for fork and exec)
```

```
[ /etc/pam.d/ ]

(login)
auth       required     pam_securetty.so
auth       requisite    pam_nologin.so
auth       include      system-local-login
account    include      system-local-login
session    include      system-local-login

(system-local-login)
auth      include   system-login
account   include   system-login
password  include   system-login
session   include   system-login

(system-login)
auth       required   pam_tally.so         onerr=succeed file=/var/log/faillog
auth       required   pam_shells.so
auth       requisite  pam_nologin.so
auth       include    system-auth
account    required   pam_access.so
account    required   pam_nologin.so
account    include    system-auth
password   include    system-auth
session    optional   pam_loginuid.so
session    include    system-auth
session    optional   pam_motd.so          motd=/etc/motd
session    optional   pam_mail.so          dir=/var/spool/mail standard quiet
-session   optional   pam_systemd.so
session    required   pam_env.so

(system-auth)
auth      required  pam_unix.so     try_first_pass nullok
auth      optional  pam_permit.so
auth      required  pam_env.so
account   required  pam_unix.so
account   optional  pam_permit.so
account   required  pam_time.so
password  required  pam_unix.so     try_first_pass nullok sha512 shadow
password  optional  pam_permit.so
session   required  pam_limits.so
session   required  pam_unix.so
session   optional  pam_permit.so

(system-service) TOOD: does this mean systemd's service ?
auth      sufficient  pam_permit.so
account   include     system-auth
session   optional    pam_loginuid.so
session   required    pam_limits.so
session   required    pam_unix.so
session   optional    pam_permit.so
session   required    pam_env.so


[ /etc/security/limits.d ]

(99-audio.conf (from jack installation))
@audio 	- rtprio 	99
@audio 	- memlock 	unlimited
```


# TODO

- pam(8), pam.d(5)
  - pam_systemd.so

    ```
    # /etc/pam.d/login
    session    include      system-local-login

    # /etc/pam.d/system-login
    session   optional   pam_systemd.so # <= pam_systemd.so will start "systemd --user" for initial login (via user@.service)
    ```

  - pam_unix.so

    ```
    # /etc/pam.d/sudo
    auth		include		system-auth

    # /etc/pam.d/system-auth
    auth      required  pam_unix.so     try_first_pass nullok
    auth      optional  pam_permit.so
    ...
    ```

- effective user id (file, real)
- apparmor(7)
- capabilities(7)
- xattr(7)
- seccomp(2)
- policykit
- logind
- gnome keyring
- Documentation/security/
- selinux

- by example
  - rkt
  - docker
  - chromium

# Reference

- https://wiki.archlinux.org/index.php/Security
