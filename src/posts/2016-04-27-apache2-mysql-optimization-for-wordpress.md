<!--
{
  "title": "Apache2, MySQL Optimization (for Wordpress)",
  "date": "2016-04-27T07:01:41.000Z",
  "category": "",
  "tags": [
    "wordpress",
    "mysql",
    "apache"
  ],
  "draft": false
}
-->

__UPDATE: 2016/05/25__

It turned out the problem of memory shortage is because of famous XML-RPC Attacks. I followed this article [digitalocean: how-to-protect-wordpress-from-xml-rpc-attacks-on-ubuntu-14-04](https://www.digitalocean.com/community/tutorials/how-to-protect-wordpress-from-xml-rpc-attacks-on-ubuntu-14-04). My change is [here](https://github.com/hi-ogawa/wordpress_ansible/commit/80b15ae6b01b94b60d99379284749e06a2d5706d).

---

Today, I came across "Error establishing a database connection" for the first time. If I checked on the server and run `sudo service mysql status`, it was not running. Then, I restarted manually by `sudo service mysql start`, but the same error happened in a moment.

This wordpress is run on AWS EC2 micro instance (which only has 1GB memory). As a temporary solution, I made [1GB of swap memory](http://wp.hiogawa.net/2016/04/25/add-memory-with-swap-file/) and I went to figure out the cause of the problem.

Simply put, it was a memory shortage and that came from Apache2 and MySQL. These changes are solution I found from some of the references:

### Apache2

For the file `/etc/apache2/mods-available/mpm_prefork.conf`, I changed from this:

```
<IfModule mpm_prefork_module>
	StartServers			 5
	MinSpareServers		  5
	MaxSpareServers		 10
	MaxRequestWorkers	  150
	MaxConnectionsPerChild   0
</IfModule>
```

to this:

```
<IfModule mpm_prefork_module>
	StartServers		1
	MinSpareServers		1
	MaxSpareServers		5
	MaxRequestWorkers	20
	MaxConnectionsPerChild   0
</IfModule>
```

### MySQL

For the file `/etc/mysql/my.cnf`, I changed from this:

```
...
key_buffer		= 16M
max_allowed_packet	= 16M
thread_stack		= 192K
thread_cache_size       = 8
...
myisam-recover         = BACKUP
max_connections        = 100
...
```

to this:

```
...
key_buffer		= 16M
max_allowed_packet	= 16M
thread_stack		= 192K
thread_cache_size       = 1     # from 8 to 1
...
myisam-recover         = BACKUP
max_connections        = 10     # from 100 to 10
...
```

### Results from `htop` and `ps`

I'll show screenshots of `htop` and the number of child processes obtained by `ps`. Here is __Before__ and __After__:

__Before__

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-27_2257.png"><img src="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-27_2257-1024x949.png" alt="2016-04-27_2257" width="580" height="538" class="alignnone size-large wp-image-217" /></a>

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-27_2258.png"><img src="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-27_2258-1024x903.png" alt="2016-04-27_2258" width="580" height="511" class="alignnone size-large wp-image-218" /></a>


```
# show the number of child processes by `ps` command
$ ps -e -T | grep apache2 | wc
    151     755    5738
$ ps -e -T | grep mysqld | wc
    167     835    6179
```

__After__

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-28_0016.png"><img src="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-28_0016-1024x920.png" alt="2016-04-28_0016" width="580" height="521" class="alignnone size-large wp-image-219" /></a>


```
# show the number of child processes by `ps` command
$ ps -e -T | grep apache2 | wc
      6      30     228
$ ps -e -T | grep mysqld | wc
     17      85     629
```


Of course, those changes are applied by using `ansible`. I extended my scripts accordingly. [Here](https://github.com/hi-ogawa/wordpress_ansible/compare/39929a40d625423487df4cbbbe325d6a1808055f...beecd0a2c13338b05dbaf557f7b47bc8d376b72c) is a diff from my public repository.


### References

- MySQL
  - [stackoverflow: how-can-i-set-the-max-number-of-mysql-processes-or-threads](http://stackoverflow.com/questions/621516/how-can-i-set-the-max-number-of-mysql-processes-or-threads)
  - [serverfault: limit-mysql-forked-processes](http://serverfault.com/questions/568626/limit-mysql-forked-processes)

- Apache2
  - [digitalocean: how-to-optimize-apache-web-server-performance](https://www.digitalocean.com/community/tutorials/how-to-optimize-apache-web-server-performance)
  - [official document: MaxRequestWorkers](https://httpd.apache.org/docs/trunk/mod/mpm_common.html#maxrequestworkers)
      - `MaxRequestWorkers` is a new syntax replacing `MaxClients`

- top, htop, ps
  - [mugurel.sumanariu.ro: the-difference-among-virt-res-and-shr-in-top-output](http://mugurel.sumanariu.ro/linux/the-difference-among-virt-res-and-shr-in-top-output/)