<!--
{
  "title": "Application Container",
  "date": "2017-05-19T11:48:35+09:00",
  "category": "",
  "tags": ["network", "linux"],
  "draft": true
}
-->

# TODO

- Fundamentals
  - network
  - namespace
  - cgroup
  - pty attaching


# Docker family

- build from source: https://git.archlinux.org/svntogit/community.git/tree/trunk/PKGBUILD?h=packages/docker

- main executables
  - dockerd (moby)
  - proxy (libnetwork)
  - containerd, containerd-shim
  - runc

- client tools
  - docker (moby)
  - ctr (containrd)
  - docker-compose

- readings
  - https://github.com/opencontainers/image-spec/blob/master/spec.md
  - https://github.com/opencontainers/runtime-spec/blob/master/spec.md
  - https://github.com/containerd/containerd/tree/master/design
  - https://github.com/docker/libnetwork/blob/master/docs/design.md
  - https://docs.docker.com/engine/api/v1.29

```
[ runc ]
follow create, start, exec

[ containerd, ctr ]

[ proxy (libnetwork) ]

[ dockerd ]


[ docker interface ]

$ systemctl start docker.service
$ ps ww -eH -o cmd | grep docker
  /usr/bin/dockerd -H fd://
    docker-containerd -l unix:///var/run/docker/libcontainerd/docker-containerd.sock --metrics-interval=0 --start-timeout 2m --state-dir /var/run/docker/libcontainerd/containerd --shim docker-containerd-shim --runtime docker-runc

$ docker image pull busybox
$ function jsonpp() { sudo cat $1 | ruby -r json -e 'puts JSON.pretty_generate(JSON.parse(STDIN.read))'; }
$ jsonpp /var/lib/docker/image/overlay2/repositories.json
{
  "Repositories": {
    "busybox": {
      "busybox:latest": "sha256:c75bebcdd211f41b3a460c7bf82970ed6c75acaab9cd4c9a4e125b03ca113798",
      "busybox@sha256:c79345819a6882c31b41bc771d9a94fc52872fa651b36771fbe0c8461d7ee558": "sha256:c75bebcdd211f41b3a460c7bf82970ed6c75acaab9cd4c9a4e125b03ca113798"
    },
    ...
  }
}
$ jsonpp /var/lib/docker/image/overlay2/imagedb/content/sha256/c75bebcdd211f41b3a460c7bf82970ed6c75acaab9cd4c9a4e125b03ca113798
{
  "architecture": "amd64",
  "config": { ... },
  ...
  "rootfs": {
    "type": "layers",
    "diff_ids": [
      "sha256:4ac76077f2c741c856a2419dfdb0804b18e48d2e1a9ce9c6a3f0605a2078caba"
    ]
  }
}
$ sudo gzip -cd /var/lib/docker/image/overlay2/layerdb/sha256/4ac76077f2c741c856a2419dfdb0804b18e48d2e1a9ce9c6a3f0605a2078caba/tar-split.json.gz
{"type":2,"payload":"YmluLwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAwNDA3NTUAMDAwMDAwMAAwMDAwMDAwADAwMDAwMDAwMDAwADEzMTA2NDE0MTY0ADAxMDAyMAAgNQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB1c3RhcgAwMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwMDAwMDAwADAwMDAwMDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=","position":0}
{"type":1,"name":"bin/","payload":null,"position":1}
{"type":2,"payload":"YmluL1sAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAxMDA3NTUAMDAwMDAwMAAwMDAwMDAwADAwMDAzNzI1MjMwADEzMTA2NDE0MTY0ADAxMDE3MQAgMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB1c3RhcgAwMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAwMDAwMDAwADAwMDAwMDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=","position":2}
{"type":1,"name":"bin/[","size":1026712,"payload":"aIZXoO6A5vM=","position":3}
...

$ docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
246ec7e4ed35        bridge              bridge              local

$ docker container create --name somecontainer --publish=4567:4567 --network=bridge busybox sh
6b3d9ac5ea953b6e0b5143aeb7c860199239e11a0780fc5f3c4572c8dc5cf00b
$ jsonpp /var/lib/docker/containers/6b3d9ac5ea953b6e0b5143aeb7c860199239e11a0780fc5f3c4572c8dc5cf00b/config.v2.json
{
  "StreamConfig": {
  },
  "State": {
    "Running": false,
    "Paused": false,
    "Restarting": false,
    "OOMKilled": false,
    "RemovalInProgress": false,
    "Dead": false,
    "Pid": 0,
    "ExitCode": 0,
    "Error": "",
    "StartedAt": "0001-01-01T00:00:00Z",
    "FinishedAt": "0001-01-01T00:00:00Z",
    "Health": null
  },
  "ID": "6b3d9ac5ea953b6e0b5143aeb7c860199239e11a0780fc5f3c4572c8dc5cf00b",
  "Created": "2017-05-21T09:17:54.571675398Z",
  "Managed": false,
  "Path": "sh",
  "Args": [

  ],
  "Config": {
    "Hostname": "6b3d9ac5ea95",
    "Domainname": "",
    "User": "",
    "AttachStdin": false,
    "AttachStdout": true,
    "AttachStderr": true,
    "ExposedPorts": {
      "4567/tcp": {
      }
    },
    "Tty": false,
    "OpenStdin": false,
    "StdinOnce": false,
    "Env": [
      "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    ],
    "Cmd": [
      "sh"
    ],
    "Image": "busybox",
    "Volumes": null,
    "WorkingDir": "",
    "Entrypoint": null,
    "OnBuild": null,
    "Labels": {
    }
  },
  "Image": "sha256:c75bebcdd211f41b3a460c7bf82970ed6c75acaab9cd4c9a4e125b03ca113798",
  "NetworkSettings": {
    "Bridge": "",
    "SandboxID": "",
    "HairpinMode": false,
    "LinkLocalIPv6Address": "",
    "LinkLocalIPv6PrefixLen": 0,
    "Networks": {
      "bridge": {
        "IPAMConfig": null,
        "Links": null,
        "Aliases": null,
        "NetworkID": "",
        "EndpointID": "",
        "Gateway": "",
        "IPAddress": "",
        "IPPrefixLen": 0,
        "IPv6Gateway": "",
        "GlobalIPv6Address": "",
        "GlobalIPv6PrefixLen": 0,
        "MacAddress": "",
        "IPAMOperational": false
      }
    },
    "Service": null,
    "Ports": null,
    "SandboxKey": "",
    "SecondaryIPAddresses": null,
    "SecondaryIPv6Addresses": null,
    "IsAnonymousEndpoint": false,
    "HasSwarmEndpoint": false
  },
  "LogPath": "",
  "Name": "/somecontainer",
  "Driver": "overlay2",
  "MountLabel": "",
  "ProcessLabel": "",
  "RestartCount": 0,
  "HasBeenStartedBefore": false,
  "HasBeenManuallyStopped": false,
  "MountPoints": {
  },
  "SecretReferences": null,
  "AppArmorProfile": "",
  "HostnamePath": "",
  "HostsPath": "",
  "ShmPath": "",
  "ResolvConfPath": "",
  "SeccompProfile": "",
  "NoNewPrivileges": false
}
$ jsonpp /var/lib/docker/containers/6b3d9ac5ea953b6e0b5143aeb7c860199239e11a0780fc5f3c4572c8dc5cf00b/hostconfig.json
{
  "Binds": null,
  "ContainerIDFile": "",
  "LogConfig": {
    "Type": "json-file",
    "Config": {
    }
  },
  "NetworkMode": "bridge",
  "PortBindings": {
    "4567/tcp": [
      {
        "HostIp": "",
        "HostPort": "4567"
      }
    ]
  },
  "RestartPolicy": {
    "Name": "no",
    "MaximumRetryCount": 0
  },
  "AutoRemove": false,
  "VolumeDriver": "",
  "VolumesFrom": null,
  "CapAdd": null,
  "CapDrop": null,
  "Dns": [

  ],
  "DnsOptions": [

  ],
  "DnsSearch": [

  ],
  "ExtraHosts": null,
  "GroupAdd": null,
  "IpcMode": "",
  "Cgroup": "",
  "Links": null,
  "OomScoreAdj": 0,
  "PidMode": "",
  "Privileged": false,
  "PublishAllPorts": false,
  "ReadonlyRootfs": false,
  "SecurityOpt": null,
  "UTSMode": "",
  "UsernsMode": "",
  "ShmSize": 67108864,
  "Runtime": "runc",
  "ConsoleSize": [
    0,
    0
  ],
  "Isolation": "",
  "CpuShares": 0,
  "Memory": 0,
  "NanoCpus": 0,
  "CgroupParent": "",
  "BlkioWeight": 0,
  "BlkioWeightDevice": null,
  "BlkioDeviceReadBps": null,
  "BlkioDeviceWriteBps": null,
  "BlkioDeviceReadIOps": null,
  "BlkioDeviceWriteIOps": null,
  "CpuPeriod": 0,
  "CpuQuota": 0,
  "CpuRealtimePeriod": 0,
  "CpuRealtimeRuntime": 0,
  "CpusetCpus": "",
  "CpusetMems": "",
  "Devices": [

  ],
  "DeviceCgroupRules": null,
  "DiskQuota": 0,
  "KernelMemory": 0,
  "MemoryReservation": 0,
  "MemorySwap": 0,
  "MemorySwappiness": -1,
  "OomKillDisable": false,
  "PidsLimit": 0,
  "Ulimits": null,
  "CpuCount": 0,
  "CpuPercent": 0,
  "IOMaximumIOps": 0,
  "IOMaximumBandwidth": 0
}

$ docker container start -a someconatiner
$ ps ww -eH -o cmd | grep docker
  /usr/bin/dockerd -H fd://
    docker-containerd -l unix:///var/run/docker/libcontainerd/docker-containerd.sock --metrics-interval=0 --start-timeout 2m --state-dir /var/run/docker/libcontainerd/containerd --shim docker-containerd-shim --runtime docker-runc
      docker-containerd-shim fc84f4d53456322f83f75ac5bfd811680ba536a2fa354a2307063c912165af11 /var/run/docker/libcontainerd/fc84f4d53456322f83f75ac5bfd811680ba536a2fa354a2307063c912165af11 docker-runc
        (sh)
    /usr/sbin/docker-proxy -proto tcp -host-ip 0.0.0.0 -host-port 4567 -container-ip 172.17.0.2 -container-port 4567

$ (network config and daemon)

$ (docker building OCI image)
```


# Networking

- components
  - veth
  - bridge
  - iptables (MASQUERADE, DNAT)
  - (docker builtin tcp proxy ?)
  - (docker builtin DNS ?)
- guest <=> internet
- guest <=> host
- https://docs.docker.com/engine/userguide/networking/default_network/binding/


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
