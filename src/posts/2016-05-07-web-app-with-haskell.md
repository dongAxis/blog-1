<!--
{
  "title": "Web App with Haskell",
  "date": "2016-05-07T01:05:50.000Z",
  "category": "",
  "tags": [
    "haskell",
    "web",
    "snap"
  ],
  "draft": false
}
-->

This post is about my first trial of creating web application with Haskell.
Source code is here: [hi-ogawa/snap-todo-app](https://github.com/hi-ogawa/snap-todo-app).

---

I read some of references comparing Haskell web frameworks:

- https://wiki.haskell.org/Web/Frameworks
- https://www.reddit.com/r/haskell/comments/332s1k/what_haskell_web_framework_do_you_use_and_why/
- http://stackoverflow.com/questions/5645168/comparing-haskells-snap-and-yesod-web-framework

For starter, I decided to go with the stack below:

- Web server with Snap: http://snapframework.com/,
- Postgresql db interface with postgresql-simple: http://hackage.haskell.org/package/postgresql-simple,
- Testing/Deployment with Docker.

I'm not familiar with _Template Haskell_ kinds of GHC magical extension, so I chose [Snap](http://snapframework.com/) instead of [Yesod](http://www.yesodweb.com/). The reason why I didn't use [persistent](https://www.stackage.org/package/persistent) is same.

# Database

Relevant code: https://github.com/hi-ogawa/snap-todo-app/blob/3afda0329dfd4f6884e726ca6ef290f58b49ce31/src/Todo.hs

It's a shame, but I really had never written raw SQL command by hand since I totally relied on ruby ORM. So, I needed to start with some of basics about database.

- PostgreSQL Basics:
  - tutorialspoint: postgresql: http://www.tutorialspoint.com/postgresql/index.htm
  - official documentation: http://www.postgresql.org/docs/9.4/static/

_Migration_

For now, I manage migration by hand with ".sql" files. Since I was using docker for preparing db, the command was like below:

```
$ psql -U postgres -w -h $(docker-machine ip default) -p 5432 postgres < db/migrations/20160501_create_todo_table.sql
```

# Development

- No haskell stack: https://github.com/commercialhaskell/stack
- cabal sandbox
- Emacs with haskell-mode and ghc-mod

# Deployment

I used [docker-compose](https://github.com/hi-ogawa/snap-todo-app/blob/cb25454fc676443be599287d28bd5aebf4838aa3/docker-compose.yml) to setup below stack at once:

- snap application
- nginx web server
- postgresql

Here are dependent docker images:

- haskell: https://hub.docker.com/_/haskell/
- nginx: https://hub.docker.com/_/nginx/
- postgres: https://hub.docker.com/_/postgres/

# Testing

With similar [docker-compose script](https://github.com/hi-ogawa/snap-todo-app/blob/819221f21c7207f58c8b13700f78f16664498b60/docker-compose.test.yml), I setup continuous integration on [jenkins](http://jenkins.hiogawa.net/job/snap_todo_app/).

# Small Tips

- [Adminer](https://hub.docker.com/r/hiogawa/adminer/) was my buddy helping me to try and debug postgresql queries.
- Nginx server_name directive:
  - http://stackoverflow.com/questions/9824328/why-is-nginx-responding-to-any-domain-name

# Future work

- Try other feature of snap:
  - Snaplet module: http://snapframework.com/docs/tutorials/snaplets-tutorial
- Try other framework:
  - Servant: http://haskell-servant.readthedocs.io/en/stable/introduction.html
  - Yesod: http://www.yesodweb.com/book
- Try solider persistence management:
  - persistent: https://www.stackage.org/package/persistent
- Try solider migration management:
  - https://wiki.postgresql.org/wiki/Change_management_tools_and_techniques
  - https://github.com/mbryzek/schema-evolution-manager
- Create frontend app, SPA by Elm: http://elm-lang.org/