<!--
{
  "title": "Add Memory with Swap File",
  "date": "2016-04-25T00:17:28.000Z",
  "category": "",
  "tags": [
    "ops"
  ],
  "draft": false
}
-->

I have a problem when building haskell programs in jenkins on AWS EC2 micro instance since cabal fails with [out of memory](https://github.com/haskell/cabal/issues/2396).
So as temporary solution, I inceresed a memory by using swapfile.

Following commands will do:

```prettyprint
$ free
             total       used       free     shared    buffers     cached
Mem:       1016324     503016     513308        384      14200     213924
-/+ buffers/cache:     274892     741432
Swap:            0          0          0
$ sudo fallocate -l 1G /swapfile
$ sudo chmod 600 /swapfile
$ sudo mkswap /swapfile
Setting up swapspace version 1, size = 1048572 KiB
no label, UUID=7e7b7fad-d5f9-4fd7-969d-7bbe39438473
$ sudo swapon /swapfile
$ free
             total       used       free     shared    buffers     cached
Mem:       1016324     503840     512484        384      14300     214184
-/+ buffers/cache:     275356     740968
Swap:      1048572          0    1048572
```

Here is one-liner version, which I often copy&paste:

```
$ sudo fallocate -l 1G /swapfile &amp;&amp; sudo chmod 600 /swapfile &amp;&amp; sudo mkswap /swapfile &amp;&amp; sudo swapon /swapfile
```
### References

- [DigitalOcean: how-to-add-swap-on-ubuntu-14-04](https://www.digitalocean.com/community/tutorials/how-to-add-swap-on-ubuntu-14-04)
- [AskUbuntu: how-do-i-disable-swap](http://askubuntu.com/questions/214805/how-do-i-disable-swap)