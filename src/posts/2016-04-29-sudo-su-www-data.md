<!--
{
  "title": "`sudo` and `su` for www-data",
  "date": "2016-04-29T00:29:57.000Z",
  "category": "",
  "tags": [
    "linux",
    "ops"
  ],
  "draft": false
}
-->

Assume user "ubuntu" is `sudo`-able.

```prettyprint
$ ssh ubuntu@....
ubuntu:/home/ubuntu $ sudo su
root:/home/ubuntu   $ exit
ubuntu:/home/ubuntu $ sudo su - root
root:/root          $ exit
ubuntu:/home/ubuntu $ sudo su - www-data -c whoami
This account is currently not available.
ubuntu:/home/ubuntu $ sudo su - www-data -s /bin/bash
www-data:/var/www   $ whoami
www-data
www-data:/var/www   $ exit
ubuntu:/home/ubuntu $ exit
```

[This problem](http://wp.hiogawa.net/2016/04/29/wordpress-revisr-setup/) is original motivation for this post.

### References

- [serverfault: bash-scripting-su-to-www-data-for-single-command](http://serverfault.com/questions/388016/bash-scripting-su-to-www-data-for-single-command#comment952918_388018)