<!--
{
  "title": "Network Service Security",
  "date": "2016-09-17T17:15:29.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->


# Some Commands

```
$ sudo nmap -sT -p1-65535 localhost

Starting Nmap 7.01 ( https://nmap.org ) at 2016-09-17 19:41 JST
Nmap scan report for localhost (127.0.0.1)
Host is up (0.00017s latency).
Not shown: 65530 closed ports
PORT      STATE SERVICE
80/tcp    open  http
9292/tcp  open  unknown
17500/tcp open  db-lsp
17600/tcp open  unknown
17603/tcp open  unknown

Nmap done: 1 IP address (1 host up) scanned in 2.89 seconds

$ sudo netstat -anp | grep tcp | grep :80 | grep LISTEN
tcp6       0      0 :::80                   :::*                    LISTEN      1562/apache2    

$ systemctl status apache2
● apache2.service - LSB: Apache2 web server
   Loaded: loaded (/etc/init.d/apache2; bad; vendor preset: enabled)
  Drop-In: /lib/systemd/system/apache2.service.d
           └─apache2-systemd.conf
   Active: active (running) since Sat 2016-09-17 19:03:13 JST; 44min ago
     Docs: man:systemd-sysv-generator(8)
  Process: 1528 ExecStart=/etc/init.d/apache2 start (code=exited, status=0/SUCCESS)
    Tasks: 55
   Memory: 8.5M
      CPU: 5.967s
   CGroup: /system.slice/apache2.service
           ├─1562 /usr/sbin/apache2 -k start
           ├─1565 /usr/sbin/apache2 -k start
           └─1566 /usr/sbin/apache2 -k start

Sep 17 19:03:12 hiogawa-thinkpad-13 systemd[1]: Starting LSB: Apache2 ...
Sep 17 19:03:12 hiogawa-thinkpad-13 apache2[1528]:  * Starting Apache ...
Sep 17 19:03:12 hiogawa-thinkpad-13 apache2[1528]: AH00558: apache2: C...
Sep 17 19:03:13 hiogawa-thinkpad-13 apache2[1528]:  *
Sep 17 19:03:13 hiogawa-thinkpad-13 systemd[1]: Started LSB: Apache2 w...
Hint: Some lines were ellipsized, use -l to show in full.

$ systemctl is-enabled apache2
```

# Reference

- https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/3/html/Security_Guide/s1-server-ports.html
- nmap:
- netstat:
- lsof'22