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

[ Socket ]
- core_initcall(sock_init) =>
  - register_filesystem(&sock_fs_type)
  - sock_mnt = kern_mount(&sock_fs_type) (will be used for allocating socket as inode)
```


# Socket life cycle

```
[ socket ]
- SYSCALL_DEFINE3(socket, int, family, int, type, int, protocol) =>
  - sock_create => __sock_create (with current namespace) =>
    - sock_alloc (will get "struct socket") =>
      - inode = new_inode_pseudo =>
        - alloc_inode => sb->s_op->alloc_inode (i.e. sockfs_ops.alloc_inode i.e. sock_alloc_inode) =>
          - sock_alloc_inode =>
            - struct socket_wq *wq = kmalloc(sizeof(*wq), GFP_KERNEL)
            - init_waitqueue_head(&wq->wait)
            - ei->socket.state = SS_UNCONNECTED
      - sock = SOCKET_I(inode)
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
    - sk->sk_wq	=	sock->wq
  - sk->sk_prot->init (e.g. tcp_v4_init_sock) (SEE BELOW)

- tcp_v4_init_sock =>
  - tcp_init_sock =>
    - setup some field as inet_connection_sock and tcp_sock
  - icsk->icsk_af_ops = &ipv4_specific


[ bind ]
- SYSCALL_DEFINE3(bind, ...) =>
  - sockfd_lookup_light
  - sock->ops->bind (e.g. inet_strram_ops.bind i.e. inet_bind) =>

- inet_bind =>
  - (tcp_proto->bind is not defined, so continue)
  - sk->sk_proto->get_port (e.g. tcp_proto.get_port i.e. inet_csk_get_port) =>
  - sk_dst_reset

- inet_csk_get_port => ...


[ listen ]
- SYSCALL_DEFINE2(listen, ...)
  - sockfd_lookup_light
  - (check backlog upper limit from sysctl_somaxconn)
  - sock->ops->listen (e.g. inet_listen) =>

- inet_listen =>
  - inet_csk_listen_start =>
    - reqsk_queue_alloc(&icsk->icsk_accept_queue)
    - sk_state_store(sk, TCP_LISTEN)
    - sk->sk_prot->get_port (again ?)
    - sk->sk_prot->hash (e.g. inet_hash) =>

- inet_hash =>
  - hlist_add_head_rcu(&sk->sk_node, &ilb->head)
  - sock_prot_inuse_add


[ accept ]
- SYSCALL_DEFINE3(accept, ...) => sys_accept4 =>
  - newsock = sock_alloc and copy type and ops
  - sock_alloc_file
  - sock->ops->accept (e.g. inet_strram_ops.accept i.e. inet_accept)
  - fd_install

- inet_accept =>
  - struct sock *sk2 = sk1->sk_prot->accept (e.g. tcp_proto.accept i.e. inet_csk_accept)
  - sock_graft(sk2, newsock) =>
    - sk->sk_wq = parent->wq (so, sk1 and sk2 belong to different wait queue)
    - sk_set_socket
  - newsock->state = SS_CONNECTED

- inet_csk_accept =>
  - if reqsk_queue_empty
    - inet_csk_wait_for_connect =>
      - prepare_to_wait_exclusive(sk_sleep(sk), ...)
      - again if reqsk_queue_empty
        - schedule_timeout
      - after wake up if !reqsk_queue_empty it returns
      - if reqsk_queue_empty loop this block as long as timeout allows
  - reqsk_queue_remove and get newsk = req->sk

Q.
- find who's gonna modify icsk->icsk_accept_queue.
- does anyone actively wakeup sleeping process ?
- someone generate request_sock.


[ connect ]
- SYSCALL_DEFINE3(connect, ...) =>
  - sock->ops->connect (e.g. inet_stream_ops.connect)

- inet_stream_connect => __inet_stream_connect =>
  - make sure socket.state is SS_UNCONNECTED
  - sk->sk_prot->connect (e.g. tcp_v4_connect)
  - if sock.sk_state is SYN_SENT or SYN_RECV, inet_wait_for_connect =>
    - while sock.sk_state is SYN_SENT or SYN_RECV
      - wait_woken(&wait, TASK_INTERRUPTIBLE, timeo)

- tcp_v4_connect =>
  - (ip route overwrites stuff ?)
  - tcp_set_state(sk, TCP_SYN_SENT)
  - tcp_connect =>
    - sk_stream_alloc_skb
    - tcp_connect_queue_skb
    - tcp_ecn_send_syn
    - tcp_send_syn_data or tcp_transmit_skb

Q.
- who modifies sock.sk_state ?
- what's available transition sock.sk_state ?


[ recv ]
[ send ]
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


# Interface management

```
```


# Reference

- IETF RFCs
  - TCP: https://tools.ietf.org/html/rfc793
  - IP: https://tools.ietf.org/html/rfc791
  - https://tools.ietf.org/html/rfc1180

- Linux Kernel Network Internal
  - Figure 13-2. big picture (link layer, ip layer, tcp layer, application layer (socket))
  - Figure 13-4: adding header for each stack
  - Figure 13-5: choosing protocol handler for each stack
  - Figure 18-1: Core functions of the IP kernel stack
  - Figure 30-9: ingress and egress traffic routing

- LDD3
  - Chapter 6 (Advanced Char Driver Operations) - Blocking I/O
