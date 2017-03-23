<!--
{
  "title": "Docker Container Zero-Downtime Deployment with Haproxy",
  "date": "2016-05-20T08:45:41.000Z",
  "category": "",
  "tags": [
    "docker",
    "haproxy"
  ],
  "draft": false
}
-->

My "weird" requirements is to realize zero-downtime deployment within single server.

I made some of "non-practical" examples:

- [hi-ogawa/docker-zero-downtime-deploy](https://github.com/hi-ogawa/docker-zero-downtime-deploy):
  - Manually setup [Haproxy](http://www.haproxy.org/)
  - Use [Ansible's polling command](http://docs.ansible.com/ansible/playbooks_loops.html#do-until-loops) to update containers without downtime
- [hi-ogawa/gantryd_trial](https://github.com/hi-ogawa/gantryd_trial):
  - Use [Gantryd](https://github.com/DevTable/gantryd)

### References

- [serversforhackers: load-balancing-with-haproxy](https://serversforhackers.com/load-balancing-with-haproxy)
- [digitalocean: how-to-use-haproxy-to-set-up-http-load-balancing-on-an-ubuntu-vps](https://www.digitalocean.com/community/tutorials/how-to-use-haproxy-to-set-up-http-load-balancing-on-an-ubuntu-vps)
- [quay: zero-downtime-deployments](https://docs.quay.io/solution/zero-downtime-deployments.html)

- Further trick about Haproxy
  - [yelp: true-zero-downtime-haproxy-reloads.html](http://engineeringblog.yelp.com/2015/04/true-zero-downtime-haproxy-reloads.html)