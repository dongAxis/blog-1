<!--
{
  "title": "Docker Container Connects to Host",
  "date": "2016-05-22T06:00:26.000Z",
  "category": "",
  "tags": [
    "docker"
  ],
  "draft": false
}
-->

Thanks to ideas from: 

- [gist: mikeclarke/7620336](https://gist.github.com/mikeclarke/7620336)
- [stackoverflow: from-inside-of-a-docker-container-how-do-i-connect-to-the-localhost-of-the-mach](http://stackoverflow.com/questions/24319662/from-inside-of-a-docker-container-how-do-i-connect-to-the-localhost-of-the-mach#answer-24326540)

---

Prepare a file `with_docker_host_ip.sh` below:

```
#!/bin/bash

export DOCKER_HOST_IP=$(ip route show | awk '/default/ {print $3}')
exec "$@"
```

Then, in your `Dockerfile`, make this executable as an entrypoint:

```
FROM ubuntu:14.04
COPY with_docker_host_ip.sh /with_docker_host_ip.sh
ENTRYPOINT ["/with_docker_host_ip.sh"]
```

When you run this image, you can see `$DOCKER_HOST_IP` is available anywhere:

```
$ docker build -t some_image .
$ docker run -it --rm some_image /bin/bash
/# echo $DOCKER_HOST_IP
172.17.0.1  
```

If you're making Rails app, your `config/database.yml` will be something like this:

```
production:
  adapter: postgresql
  encoding: unicode
  template: template0
  reconnect: true
  pool: 5
  host: <%= ENV['DOCKER_HOST_IP'] %>
  port: 5432
  database: xxxx
  username: yyyy
  password: zzzz
```

I used this on Ubuntu machine as docker host, but it didn't work for OS X.