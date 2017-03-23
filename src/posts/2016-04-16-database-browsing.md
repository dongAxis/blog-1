<!--
{
  "title": "Database Browsing",
  "date": "2016-04-16T21:58:04.000Z",
  "category": "",
  "tags": [
    "database"
  ],
  "draft": false
}
-->

When I was on my way of DIY  migrating posts data from Ghost blog to this Wordpress, I needed some tools to browse data easily (and hopefully learn some of raw SQL commands interactively).

So far I tried those tools:

- [phpMyAdmin](https://www.phpmyadmin.net/) (with [MAMP](https://www.mamp.info/))
- [stackoverflow question](http://superuser.com/questions/78088/i-just-installed-mamp-how-do-i-access-mysql-through-the-terminal) about MAMP specific mysql configuration

```

$ mysql --host=127.0.0.1 -P 8889 -uroot -proot mysql -e &quot;show databases;&quot;
Warning: Using a password on the command line interface can be insecure.
+------------------------------+
| Database |
+------------------------------+
| information_schema |
| ansible_capistrano_wordpress |
| mysql |
| odigo_blog_wordpress |
| performance_schema |
| wordpress |
| wp_hiogawa_db |
+------------------------------+

```

- [Adminer](https://www.adminer.org/)

```

$ brew tap homebrew/php

$ brew info adminer

```

I'm using MAMP for local apache, so I added the to `/Applications/MAMP/conf/apache/httpd.conf`.

```
Alias /adminer /usr/local/share/adminer
&lt;Directory &quot;/usr/local/share/adminer/&quot;&gt;
Options None
AllowOverride None

Require all granted


Order allow,deny
Allow from all


```

For starter, I downloaded ghost blog postgresql dump file (here, it's named `e370192d-5304-4856-a17d-765f771e2f14`) and browsed data.

```
$ create_db ghost_blog_db
$ pg_restore --verbose --clean --no-acl --no-owner -d heroku_hiogawa_ghost e370192d-5304-4856-a17d-765f771e2f14
```

The goodness is we can see real SQL commands through browsing, like below:

<img class="alignnone wp-image-102 size-large" src="http://wp.hiogawa.net/wp-content/uploads/2016/04/2016-04-17_1556-1024x652.png" alt="2016-04-17_1556" width="660" height="420" />