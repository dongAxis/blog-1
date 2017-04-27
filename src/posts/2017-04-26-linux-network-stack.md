<!--
{
  "title": "Linux Network Stack",
  "date": "2017-04-26T17:51:50+09:00",
  "category": "",
  "tags": ["linux", "ip", "tcp", "ethernet"],
  "draft": true
}
-->

# TODO

- Goal
  - walk through tcp server/client example
    - e.g. user space tcp interface
      - socket, bind
      - connect
      - listen, accept
      - send/recv
  - tcp, ip, ethernet stack (kernel)
  - ethernet device driver (kernel)
  - iptables, ip route, ip link, ip address

- Things on my PC, which looks relevant
  - net/wireless/cfg80211: Linux wireless LAN (802.11) configuration API
  - net/mac80211: hardware independent IEEE 802.11 networking stack
  - drivers/net/ethernet/intel/e1000e: Intel(R) PRO/1000 PCI-Express Gigabit Ethernet suppor
  - drivers/net/wireless/intel/iwlwifi: Intel Wireless WiFi Link Next-Gen AGN


# Linux source

```
- include/linux/
  - netdevice.h
    - struct net_device
    - struct net_device_ops
    - struct packet_type
    - struct header_ops
  - net_namespace.h
    - struct net
  - skbuff.h
    - struct sk_buff
  - net.h
    - struct socket
    - struct proto_ops
  - etherdevice.h
    - alloc_etherdev

- include/net/
  - sock.h
    - struct sock
    - struct proto (socket layer to transport layer interface)
  - tcp.h
    - struct tcp_sock

- include/uapi/linux/
  - if_ether.h
    - ETH_P_LOOP, ETH_P_IP, ETH_P_ARP
    - struct ethhdr


- net/
  - socket.c
    - sock_register

- net/core/
  - dev.c
    - dev_add_pack
  - sock.c
    - proto_register

- net/ethernet/
  - eth.c
    - ether_setup
    - eth_header_ops

- net/ivp4/
  - af_inet.c
    - inet_init
  - tcp.c
    - tcp_init
    - tcp_init_sock
    - tcp_recvmsg, tcp_sendmsg
  - tcp_ipv4.c
    - tcp_v4_init
    - tcp_sk_ops
    - tcp_prot
  - tcp_input.c
  - tcp_output.c  
```


# Initialization

```
[ Ethernet driver ]
- module_init(e1000_init_module) => pci_register_driver(&e1000_driver)

- e1000_probe =>
  - alloc_etherdev => alloc_etherdev_mqs => alloc_netdev_mqs(..ether_setup)
  - SET_NETDEV_DEV
  - register_netdev => register_netdevice => list_netdevice ...


[ IP/TCP stack ]
- fs_initcall(inet_init) =>
  - proto_register(&tcp_prot, 1) (tcp_prot defined in tcp_ipv4.c)
  - sock_register(&inet_family_ops) (PF_INET protocol family registration)
  - inet_add_protocol(&tcp_protocol, IPPROTO_TCP)
  - inet_register_protosw for each inet_protosw in inetsw_array (e.g. SOCK_STREAM, tcp_prot)
  - ip_init (ip_output.c) =>
    - ip_rt_init (route.c) => ?
  - tcp_init =>
    - tcp_v4_init =>
      - register_pernet_subsys(&tcp_sk_ops)
  - dev_add_pack(&ip_packet_type) (type is ETH_P_IP)
```


# Packet life cycle

```
[ ingress ]
(some ethernet driver)
- (netif_rx, netif_rx_ni)
- netif_receive_skb => ... =>
  - __netif_receive_skb_core =>
    - ...
    - deliver_skb => ip_packet_type.func (i.e. ip_rcv)

- ip_rcv =>
  - (validate checksum...)
  - NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, ..., ip_rcv_finish) => ip_rcv_finish =>
    - struct net_protocol *ipprot = rcu_dereference(inet_protos[iph->protocol])
    - ipprot->early_demux (possibly tcp_v4_early_demux) =>
      - struct sock *sk = __inet_lookup_established
      - skb_dst_set_noref(skb, sk->sk_rx_dst)
      - (Q. somewhere before inet_sk_rx_dst_set ?)
    - dst_input => skb_dst(skb)->input(skb) (dst_entry.input) =>

- Q. how to delegate to tcp stack ?
  - obviously, tcp socket has to be created beforehand and __inet_lookup_established will catch it?

[ egress ]
```


# Socket life cycle

```
[ socket ]
- SYSCALL_DEFINE3(socket, int, family, int, type, int, protocol) =>
  - sock_create => __sock_create (with current namespace) =>
    - sock_alloc (will get "struct socket") =>
      - new_inode_pseudo, SOCKET_I
    - net_proto_family.create (e.g. inet_family_ops.inet_create) (SEE BELOW)
  - sock_map_fd =>
    - sock_alloc_file => alloc_file
    - fd_install

- inet_create (for given "struct socket") =>
  - (look for matching protocol from inetsw, e.g. tcp_proto)
  - assign sock->ops (e.g inet_stream_ops)
  - sk_alloc (will get "struct sock") =>
    - sk_prot_alloc
    - assign sk->sk_proto (e.g. tcp_proto)
  - inet_sk (cast from "struct sock" to "struct inet_sock")
  - sock_init_data =>
    - sk_set_socket
  - sk->sk_prot->init (e.g. tcp_v4_init_sock) (SEE BELOW)

- tcp_v4_init_sock =>
  - tcp_init_sock =>
    - setup some field as inet_connection_sock and tcp_sock
  - icsk->icsk_af_ops = &ipv4_specific


[ bind ]
SYSCALL
- sockfd_lookup_light
- sock->ops->bind (e.g. inet_strram_ops.bind i.e. inet_bind)

inet_bind =>
- (there's no tcp_proto->bind, so continue)
- sk->sk_proto->get_port (e.g. tcp_proto i.e. inet_csk_get_port)
- sk_dst_reset

inet_csk_get_port =>
- ...?

[ listen ]
SYSCALL
- sock->ops->listen

inet_listen =>
- inet_csk_listen_start =>
  - reqsk_queue_alloc ?
  - hash ?

[ accept ]
SYSCALL
- newsock = sock_alloc amd copy type and ops
- 

inet_accept =
inet_csk_accept =>
- (check if icsk already has established connection)
- if not inet_csk_wait_for_connect =>
  - ?
- newsk = rq.sk

Q. how does it sleep and who wakes up? (some wait queue?)
  - driver side of tcp (ip) subsytem is supposed to wake up process?

[ connect ]
[ recv ]
[ send ]
```


# Interface management

```
```


# Reference

- Linux Kernel Network Internal
  - Figure 13-2. big picture (link layer, ip layer, tcp layer, application layer (socket))
  - Figure 13-4: adding header for each stack
  - Figure 13-5: choosing protocol handler for each stack
  - Figure 18-1: Core functions of the IP kernel stack
  - Figure 30-9: ingress and egress traffic routing
