<!--
{
  "title": "Reading: Understanding Linux Network Internals",
  "date": "2016-08-16T16:07:31.000Z",
  "category": "",
  "tags": [
    "linux"
  ],
  "draft": true
}
-->

Kernel versions: https://github.com/torvalds/linux/commit/194dc870a5890e855ecffb30f3b80ba7c88f96d6

- Starter Knowledges
  - https://en.wikipedia.org/wiki/OSI_model
  - http://docwiki.cisco.com/wiki/Internetworking_Technology_Handbook
      - http://docwiki.cisco.com/wiki/Internetworking_Basics
  - https://www.digitalocean.com/community/tutorials/an-introduction-to-networking-terminology-interfaces-and-protocols
  - Socket Programming: https://github.com/hi-ogawa/socket-programming-basics (L3, L4)

- part 1: `struct sk_buff`, `struct net_device`, `sysctl`
- part 2: Network device, device driver initialization (L1, L2 ??)
  - device and driver initialization
  - Figure 5-1. Kernel initialization path
  - Figure 6-1. Driver-device association via bus descriptor
  - NOTE:
     - `/sbin/hotplug` seems depreated in favor of [udev](https://en.wikipedia.org/wiki/Udev)
     - separation of `net_device_ops` from `net_device`
  - Qs.
     - how bus descriptor is initialized ?
- part 3: Frame RX/TX (between L2 and L3)
  - how to hanlde data from hardware
      - interrupt, softirq, tasklet
      - NOTE: 
            - [LWN: Eliminating tasklets](http://lwn.net/Articles/239633/)
            - []
- part 4: Bridging (L2)
- part 5: IPv4, ICMP (L3) 
- part 6: ARP (L2, L3)
- part 7: Routing (L3)

- TODO  
  - how L4 (e.g. TCP) is implemented ?