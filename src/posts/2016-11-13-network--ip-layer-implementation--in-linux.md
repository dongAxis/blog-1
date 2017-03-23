<!--
{
  "title": "Network (IP layer implementation) in Linux",
  "date": "2016-11-13T16:28:14.000Z",
  "category": "",
  "tags": [],
  "draft": true
}
-->

forget real hardware, just consider only kernel resource (keeping ip address as lowest resource (let's ignore MAC address))

- what does `listen` and `connect` do exactly (or `sendto`)?
  - ip, route table, gateway, interface
  - chap 24, show how L4 protocol register a handler!!

- I should read network internal part 5 and 7

- ifconfig
  - manage relation between _interface_ and some type of _address_ (non necessary ip address)
  - nmcli can also control some parameters
- interface
  - abstract device (so it can be virtual)
  - the name to bind "network operation" to _driver_ kernel module
- route
  * kernel ip routing
    - gateway?
    - default?
    - destination?
- iptables
  - kernel packet filtering upon IP layer
- bridge??
  - "route" functionality for protocols (network things) other than ip layer
  - bridge is still one type of interface, one type of network stack driver

# Overview

- netif_rcv
- ip_rcv
  - after route check
    - forward
      - involves transmission
    - local delivery
 - tcp (connect, listen)
  - will register handler to ip_rcv ?

# Some Commands

```
$ ip route
$ route
$ ifconfig -s
```

- when these are initialized?
  - from systemd?
  - or from programs itself (e.g. vbox, docker) 

# kernel resource

- how socket, interface, address are managed in kernel?
- socket
- interface
- address
- ip table

# Proxy implementation

- there's a bunch of `Requirements for HTTP/1.1 proxies` in https://tools.ietf.org/html/rfc2616
- and quotes from https://tools.ietf.org/html/rfc7230:
  >  A "proxy" is a message-forwarding agent that is selected by the client, usually via local configuration rules, to receive requests for some type(s) of absolute URI and attempt to satisfy those requests via translation through the HTTP interface.


# OpenVPN

- https://openvpn.net/index.php/open-source/documentation/howto.html#redirect

# Reference

- snull in ldd3
- rfc