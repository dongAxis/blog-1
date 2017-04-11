<!--
{
  "title": "Wordpress Revisr Setup",
  "date": "2016-04-29T00:59:16.000Z",
  "category": "",
  "tags": [
    "wordpress",
    "ssh"
  ],
  "draft": false
}
-->

The result of following setup is on github: [hi-ogawa/wordpress-revisr](https://github.com/hi-ogawa/wordpress-revisr).

### Ignore all but theme files

Here is a `.gitignore` file only for tracking changes on `simple-mag` theme.

```prettyprint
*
!/wp-content/
/wp-content/*
!/wp-content/themes/
/wp-content/themes/*
!/wp-content/themes/simple-mag/
!/wp-content/themes/simple-mag/*
```

### Setup remote repository

I didn't want to [hard-code my password for remote repository https url](http://stackoverflow.com/questions/5343068/is-there-a-way-to-skip-password-typing-when-using-https-on-github#answer-5343146). So, I tried ssh version of url.

Here is a screenshot of Revisr setting:

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-29_1845-1024x687.png"><img class="alignnone size-large wp-image-252" src="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-29_1845-1024x687.png" alt="2016-04-29_1845" width="580" height="389" /></a>

First, generate ssh private/public keys for user `www-data`.

```prettyprint
$ sudo mkdir /var/www/.ssh
$ sudo chown www-data:www-data /var/www/.ssh
$ sudo su - www-data -s /bin/bash -c ssh-keygen
Generating public/private rsa key pair.
Enter file in which to save the key (/var/www/.ssh/id_rsa):
Enter passphrase (empty for no passphrase):
Enter same passphrase again:
Your identification has been saved in /var/www/.ssh/id_rsa.
Your public key has been saved in /var/www/.ssh/id_rsa.pub.
...
```

Second, save generated public key to github repository as deploy key:

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-29_1849-e1461923768263-1024x593.png"><img class="alignnone wp-image-255 size-large" src="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-29_1849-e1461923768263-1024x593.png" alt="2016-04-29_1849" width="580" height="336" /></a>

Then, make sure connection is fine. Here I had a problem, so I'll show my workaround:

```prettyprint
# it fails for some reason I don't know
$ sudo su - www-data -s /bin/bash -c 'ssh -T git@github.com'
Host key verification failed.

# that's why I forced to add github.com as known host
$ sudo su - www-data -s /bin/bash -c 'ssh -o StrictHostKeyChecking=no -T git@github.com'
Warning: Permanently added 'github.com,192.30.252.121' (RSA) to the list of known hosts.
Hi hi-ogawa/wordpress-revisr! You've successfully authenticated, but GitHub does not provide shell access.

# then it's fine for all
$ sudo su - www-data -s /bin/bash -c 'ssh -T git@github.com'
Hi hi-ogawa/wordpress-revisr! You've successfully authenticated, but GitHub does not provide shell access.
```

### References

- [`sudo` and `su` for www-data](http://wp.hiogawa.net/2016/04/29/sudo-su-www-data/)
- [stackoverflow: git-ignore-everything-except-subdirectory](http://stackoverflow.com/questions/1248570/git-ignore-everything-except-subdirectory#answer-11018557)
- [askubuntu: ssh-connection-problem-with-host-key-verification-failed-error](http://askubuntu.com/questions/45679/ssh-connection-problem-with-host-key-verification-failed-error)
- [superuser: how-to-tell-git-which-private-key-to-use](http://superuser.com/questions/232373/how-to-tell-git-which-private-key-to-use)
- [github.com: testing-your-ssh-connection](https://help.github.com/articles/testing-your-ssh-connection/)