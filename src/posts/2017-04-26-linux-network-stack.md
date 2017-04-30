<!--
{
  "title": "Linux Network Stack",
  "date": "2017-04-26T17:51:50+09:00",
  "category": "",
  "tags": ["linux", "ip", "tcp", "ethernet"],
  "draft": false
}
-->

# TODO

- Goal
  - walk through tcp server/client example
    - i.e. user space tcp interface
      - socket, bind
      - connect
      - listen, accept
      - send/recv
  - tcp, ip, ethernet stack (kernel)
  - ethernet device driver (kernel)
  - link layer and ip routing utility: iptables, ip route, ip link, ip address


# Linux source

Random selection of a source file and some definition I think is important.

```
- net/
  - socket.c
    - SYSCALLs socket, bind, ...
    - sock_register

- net/core/
  - dev.c (dev_add_pack)
  - sock.c (proto_register)

- net/ethernet/
  - eth.c (ether_setup)

- net/ivp4/
  - af_inet.c (struct proto_ops inet_stream_ops)
  - route.c (ip_route_input_slow)
  - ip_input.c (ip_rcv)
  - inet_connection_sock.c (inet_csk_xxx e.g inet_csk_accept)
  - tcp_ipv4.c (struct proto tcp_prot)
  - tcp_input.c (tcp_rcv_state_process)
  - tcp_output.c (?)
  - tcp.c (?)

(Things on my machine, which looks relevant)
- net/wireless/cfg80211: Linux wireless LAN (802.11) configuration API
- net/mac80211: hardware independent IEEE 802.11 networking stack
- drivers/net/ethernet/intel/e1000e: Intel(R) PRO/1000 PCI-Express Gigabit Ethernet suppor
- drivers/net/wireless/intel/iwlwifi: Intel Wireless WiFi Link Next-Gen AGN
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
  - inet_add_protocol(&tcp_protocol, IPPROTO_TCP) => update global inet_protos
  - inet_register_protosw for each inet_protosw in inetsw_array (e.g. SOCK_STREAM, tcp_prot)
  - ip_init (ip_output.c) =>
    - ip_rt_init (route.c) => ?
  - tcp_init =>
    - tcp_v4_init =>
      - register_pernet_subsys(&tcp_sk_ops)
  - dev_add_pack(&ip_packet_type) (type is ETH_P_IP)

(global variables)
struct inet_hashinfo tcp_hashinfo
struct net_protocol *inet_protos[]


[ Socket ]
- core_initcall(sock_init) =>
  - register_filesystem(&sock_fs_type)
  - sock_mnt = kern_mount(&sock_fs_type) (will be used for allocating socket as inode)
```


# User side

[The kernel side](#kernel-side) of activities follows this section.

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
    - sk->sk_state =	TCP_CLOSE
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

- inet_hash => __inet_hash =>
  - struct inet_hashinfo *hashinfo = sk->sk_prot->h.hashinfo (e.g. tcp_hashinfo)
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
      - if reqsk_queue_empty, loop this block as long as timeout allows
  - reqsk_queue_remove and get newsk = req->sk

- Q. I see only fastopen_sk pushed into icsk_accept_queue. is it really so?


[ connect ]
- SYSCALL_DEFINE3(connect, ...) =>
  - sock->ops->connect (e.g. inet_stream_ops.connect)

- inet_stream_connect => __inet_stream_connect =>
  - make sure socket.state is SS_UNCONNECTED
  - sk->sk_prot->connect (e.g. tcp_v4_connect)
  - if sock.sk_state is SYN_SENT or SYN_RECV, inet_wait_for_connect =>
    - while sock.sk_state is SYN_SENT or SYN_RECV
      - wait_woken(&wait, TASK_INTERRUPTIBLE, timeo)
  - sock->state = SS_CONNECTED if it goes succesfully

- tcp_v4_connect =>
  - (ip routing overwrites stuff ?)
  - tcp_set_state(sk, TCP_SYN_SENT)
  - tcp_connect =>
    - sk_stream_alloc_skb
    - tcp_connect_queue_skb
    - tcp_ecn_send_syn
    - tcp_send_syn_data or tcp_transmit_skb


[ recv ]
[ send ]
```


# Kernel side

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
    - ipprot->early_demux (possibly tcp_v4_early_demux) (how could this path not even consider ip routing ?)=>
      - cast to iphdr and tcphdr
      - struct sock *sk = __inet_lookup_established =>
        - find socket INET_MATCH from tcp_hashinfo
      - if sk_fullsock (i.e. ~(TCPF_TIME_WAIT | TCPF_NEW_SYN_RECV))
        - skb_dst_set_noref(skb, sk->sk_rx_dst)
    - if not skb_valid_dst(skb)
      - ip_route_input_noref(skb, ...) => (SEE BELOW)
    - rt = skb_rtable(skb) and do something depending on rt->rt_type ...
    - dst_input(skb) => skb_dst(skb)->input(skb) (dst_entry.input) (SEE BELOW for "local delivery")

- ip_route_input_noref =>
  - ip_route_input_slow =>
    - fib_lookup (foward information base) => ?
    - if fib_result.type == RTN_LOCAL
      - fib_validate_source => ?
      - goto local_input
        - FIB_RES_NH(res).nh_rth_input
        - rt_dst_alloc =>
          - struct rtable *rt = dst_alloc
          - rt->dst.output = ip_output
          - rt->dst.input = ip_local_deliver if RTCF_LOCAL
        - skb_dst_set(skb, &rth->dst)  


[ ingress: local delivery ]
- ip_local_deliver =>
  - if ip_is_fragment, ip_defrag
  - ip_local_deliver_finish =>
    - int protocol = ip_hdr(skb)->protocol
    - struct net_protocol *ipprot = inet_protos[protocol]
    - ipprot->handler(skb) (e.g. tcp_protocol.handler is tcp_v4_rcv)

- tcp_v4_rcv =>
  - struct sock *sk = __inet_lookup_skb
  - tcp_v4_inbound_md5_hash
  - tcp_filter
  - tcp_v4_do_rcv (mostly comes here ?) =>
    - tcp_rcv_state_process =>
      - struct tcphdr *th = tcp_hdr(skb)
      - (if sk->sk_state == TCP_LISTEN and th->syn)
        - icsk->icsk_af_ops->conn_request(sk, skb) (e.g. tcp_v4_conn_request) =>
          - tcp_conn_request(&tcp_request_sock_ops, &tcp_request_sock_ipv4_ops, sk, skb) => (SEE BELOW)
        - consume_skb(skb) (freeing stuff)
        - return 0
      - tcp_check_req => ?
      - tcp_ack
      - (if sk->sk_state == TCP_SYN_RECV)
        - tcp_init_congestion_control
        - tcp_set_state(sk, TCP_ESTABLISHED)
        - sk_wake_async(sk, SOCK_WAKE_IO, POLL_OUT) (comment says this is not for waking up listening/accepting socket)

- tcp_conn_request =>
  - inet_reqsk_alloc =>
    - struct request_sock *req = reqsk_alloc
  - tcp_openreq_init
  - af_ops->init_req (i.e. tcp_v4_init_req)
  - af_ops->send_synack (i.e. tcp_v4_reqsk_send_ack) =>
    - tcp_v4_send_ack => ip_send_unicast_reply => ip_push_pending_frames =>
      - ip_finish_skb
      - ip_send_skb => ip_local_out => __ip_local_out =>
        - (let's not follow ip egress routine anymore...)
  - (Q. what's fastopen? anyway, let's assume it whatever that is.)
  - struct sock *fastopen_sk = tcp_try_fastopen      
  - inet_csk_reqsk_queue_add =>
    - req->sk = fastopen_sk
    - update icsk_accept_queue (this queue is watched by socket accept syscall)
  - Q?. when do we update sk->sk_state to TCP_SYN_RECV or something ?


[ ingress: forwarding ]
- branch off from (ip_rcv => ... => ip_route_input_noref) =>
  - ip_route_input_slow =>
    - if not res.type == RTN_LOCAL
      - ip_mkroute_input => __mkroute_input =>
        - rt_dst_alloc
        - rth->dst.input = ip_forward
        - skb_dst_set(skb, &rth->dst)

- ip_forward => ...


[ egress ]
- Q? egress path as in ip_send_unicast_reply
- Q? egress path as in active OPEN (e.g. connect)
- Q? where does ip routing come in ? (something like ip_route_input_noref for output ?)
```


# Interface management


# IP Routing management


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
