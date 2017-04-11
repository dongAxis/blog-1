<!--
{
  "title": "Hash, Cryptograpy",
  "date": "2016-09-06T16:10:46.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

# Secure Password

Scenario

- user have hashed password
- user don't have hashed password

Common Attacks

- rainbow table
- brute force

Common Technique

- salting (to avoid rainbow table)
- key stretching (to avoid brute force)

Example

- Bcrypt password hash encryption

# Hash function usage and characteristics

- https://en.wikipedia.org/wiki/Hash_function
- https://en.wikipedia.org/wiki/Cryptographic_hash_function
- 

# Example from Unix System

- https://www.openssl.org/docs/manmaster/apps/openssl.html
- http://man7.org/linux/man-pages/man3/crypt.3.html
- http://man7.org/linux/man-pages/man5/shadow.5.html
- http://man7.org/linux/man-pages/man1/passwd.1.html

```
$ sudo passwd hiogawa
Enter new UNIX password: a1b2c3d4
Retype new UNIX password: a1b2c3d4
passwd: password updated successfully
$ sudo cat /etc/shadow | grep hiogawa
hiogawa:$6$oifbdQNc$U5U3vsWNNRbkck6E25UXxBchmtuZPjnIVCq51NRnx/g/.qPOf/FFY/fqFva7wZDKGVyFzl.ZHUSJ76T7RBmdt/:17050:0:99999:7:::
# 6 <= SHA-512
# oifbdQNc <= salt (8 characters)
# U5U3v... <= encrypted hash (86 characters)
$ openssl
```

# References

- https://en.wikipedia.org/wiki/Hash-based_message_authentication_code