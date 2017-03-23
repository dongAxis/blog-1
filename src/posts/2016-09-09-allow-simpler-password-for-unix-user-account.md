<!--
{
  "title": "Allow Simpler Password for Unix User Account",
  "date": "2016-09-09T20:20:12.000Z",
  "category": "",
  "tags": [
    "linux",
    "pam"
  ],
  "draft": false
}
-->

# Relevant Man Pages

- passwd(1)
- pam(7)
- pam_unix(8)

# What I Did

There are two files look important:

- in _/etc/pam.d/passwd_,

```
@include common-password
```

- in _/etc/pam.d/common-password_,

```
password	[success=1 default=ignore]	pam_unix.so obscure sha512
password	requisite			pam_deny.so
password	required			pam_permit.so
password	optional	pam_gnome_keyring.so 
```

As I read _pam_unix(8)_, I found: 

- _abscure_ enables the password strength check and,
- minimal password length (which is set by _min_len_) is 6

So, I changed the first line to:

```
password	[success=1 default=ignore]	pam_unix.so sha512 min_len=2
```

Then, it became possible to update to super weak password with _passwd(1)_:

```
$ passwd
Changing password for hiogawa.
(current) UNIX password: ? 
Enter new UNIX password: ?
Retype new UNIX password: ?
passwd: password updated successfully
```