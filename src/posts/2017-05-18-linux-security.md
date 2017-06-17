<!--
{
  "title": "Linux Security",
  "date": "2017-05-18T12:28:03+09:00",
  "category": "",
  "tags": ["linux"],
  "draft": true
}
-->

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
