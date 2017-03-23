<!--
{
  "title": "Studying BitTorrent and Peer-to-Peer",
  "date": "2016-11-06T01:41:50.000Z",
  "category": "",
  "tags": [
    "internet"
  ],
  "draft": false
}
-->

# Components

- Programs
  - Host side
      - web server (http)
          - serve .torrent file with minetype application/x-bittorrent
      - torrent tracker (http)
          - respond to GET request with information about peers (or downloaders)
            following http://www.bittorrent.org/beps/bep_0003.html#trackers
      - "origin" downloader (tcp)
          - work as first peer to communicate with end-user's downloader
  - End-user side
      - web browser (http)
          - browse and find .torrent files on the Internet
      - downloader (tcp)
          - work as one peer and obtain file

- Data
  - file to distribute
  - _.torrent_ file
      - consist of url to torrent tracker and some information about the file to be distributed

# Implementation

- Tracker
  - https://github.com/feross/bittorrent-tracker
- Downloader (a.k.a. client)
  - https://en.wikipedia.org/wiki/Comparison_of_BitTorrent_clients

# References

- BitTorrent protocol
  - http://www.bittorrent.org/beps/bep_0003.html
- P2P over NAT
  - http://www.brynosaurus.com/pub/net/p2pnat/
  - https://tools.ietf.org/html/rfc5128
- NAT
  - https://tools.ietf.org/html/rfc2663
- UPnP/NAT-PMP
  - https://tools.ietf.org/html/rfc6886