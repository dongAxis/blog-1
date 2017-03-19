My personal blog.

```
# Development

$ cd ./scripts
$ bundle install
$ mkdir -p ../out/posts

 - from one shell -
$ WATCH=yes SRC=../src OUT=../out bundle exec ruby ./build.rb

 - from another shell -
$ OUT=../out bundle exec ruby server.rb # vist localhost:8000/index.html


# Deployment

$ SRC=../src OUT=../out ./deploy.sh
```

- TODO
  - migration from wp.hiogwa.net
    - post and photo assets
  - design and css
    - header
    - index page post list
    - markdown content
