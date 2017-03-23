<!--
{
  "title": "Migration solution with docker-compose",
  "date": "2016-05-22T07:49:05.000Z",
  "category": "",
  "tags": [
    "haskell",
    "docker",
    "database"
  ],
  "draft": false
}
-->

Since I tried to create [web application with Haskell](http://wp.hiogawa.net/2016/05/07/web-app-with-haskell/), I've been looking for general way of managing database migration.

So far, I found two software looking good to me:

- [standalone-migrations](https://github.com/thuss/standalone-migrations)
- [Flyway](https://flywaydb.org/)

I'm used to ruby, so I decided to make a dockerized application of [standalone-migrations](https://github.com/thuss/standalone-migrations) and use it from Haskell app connecting with Postgresql.

Here are relevant repositories:

- Docker container [dockerhub: hiogawa/standalone-migrations](https://hub.docker.com/r/hiogawa/standalone-migrations/)
  - Source code is here: [github hi-ogawa/docker-standalone-migrations](https://github.com/hi-ogawa/docker-standalone-migrations)
- docker-compose example [github hi-ogawa/docker-compose-standalone-migrations-example](https://github.com/hi-ogawa/docker-compose-standalone-migrations-example)

You can read usages from each README files.