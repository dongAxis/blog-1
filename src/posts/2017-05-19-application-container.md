<!--
{
  "title": "Container",
  "date": "2017-05-19T11:48:35+09:00",
  "category": "",
  "tags": ["network", "linux"],
  "draft": true
}
-->


# TODO

- namespace
- cgroup
- terminal attaching
- networking
  - components
    - veth
    - bridge
    - iptables (MASQUERADE, DNAT)
    - (docker builtin tcp proxy ?)
    - (docker builtin DNS ?)
  - guest <=> internet
  - guest <=> host

```
(Guest <=> Internet)

# Host
$ docker ps
CONTAINER ID    ...   PORTS                    ...
8e9a991a3816    ...   0.0.0.0:3000->3000/tcp   ...

$ ip ro
default via 192.168.1.1 dev wlp3s0  proto static  metric 600
172.20.0.0/16 dev br-e537d0a07190  proto kernel  scope link  src 172.20.0.1

$ ip addr
5: br-e537d0a07190: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:99:e2:be:2e brd ff:ff:ff:ff:ff:ff
    inet 172.20.0.1/16 scope global br-e537d0a07190
       valid_lft forever preferred_lft forever
    inet6 fe80::42:99ff:fee2:be2e/64 scope link
       valid_lft forever preferred_lft forever
22: veth7b062e7@if21: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br-e537d0a07190 state UP group default
    link/ether be:84:6f:4d:9a:2e brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet6 fe80::bc84:6fff:fe4d:9a2e/64 scope link
       valid_lft forever preferred_lft forever

$ iptables -t nat -L
MASQUERADE  all  --  172.20.0.0/16        anywhere            
DNAT       tcp  --  anywhere             anywhere             tcp dpt:3000 to:172.20.0.2:3000

# Guest
$ ip ro
default via 172.20.0.1 dev eth0
172.20.0.0/16 dev eth0  proto kernel  scope link  src 172.20.0.2

$ ip addr
21: eth0@if22: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:ac:14:00:02 brd ff:ff:ff:ff:ff:ff
    inet 172.20.0.2/16 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:acff:fe14:2/64 scope link
       valid_lft forever preferred_lft forever
```

# References

- https://docs.docker.com/engine/userguide/networking/default_network/binding/
