<!--
{
  "title": "Bash Regular Expression",
  "date": "2016-09-25T22:49:45.000Z",
  "category": "",
  "tags": [
    "bash"
  ],
  "draft": true
}
-->

```
$ bash --version
GNU bash, version 4.3.46(1)-release (x86_64-pc-linux-gnu)
Copyright (C) 2013 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later &lt;http://gnu.org/licenses/gpl.html&gt;

This is free software; you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
```

```
$ for f in config/*; do ([[ $f =~ config/(.*).yml.example ]] && cp config/${BASH_REMATCH[1]}.yml.example config/${BASH_REMATCH[1]}.yml); done
```

```
$ ls config/ | xargs -I @ bash -c '[[ @ =~ (.*).yml.example ]] && echo ${BASH_REMATCH[1]}'
```