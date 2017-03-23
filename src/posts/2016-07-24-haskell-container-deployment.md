<!--
{
  "title": "Haskell Container Deployment",
  "date": "2016-07-24T00:13:43.000Z",
  "category": "",
  "tags": [
    "haskell",
    "docker",
    "heroku"
  ],
  "draft": false
}
-->

This post explains how I deployed Yesod application on Heroku. Code is available here: https://github.com/hi-ogawa/yesod-experiment

I put whole process into single [`docker-compose.yml`](https://github.com/hi-ogawa/yesod-experiment/blob/master/systems/docker-compose.yml) file. Main services are listed below:

- `test`: run `cabal test`
- `builder`: run `cabal install` and create tar file of executable called `production.tar.gz`
- `distributor`: build production image following `Dockerfile.dist`
- `flyway_production`: run migration on production db by using  [flyway](https://flywaydb.org/) as [dockerized one](https://github.com/hi-ogawa/docker-flyway)

# Architecture

<a href="http://wp.hiogawa.net/wp-content/uploads/2016/07/2016-07-24-18.11.18-1024x768.jpg"><img src="http://wp.hiogawa.net/wp-content/uploads/2016/07/2016-07-24-18.11.18-1024x768.jpg" alt="2016-07-24 18.11.18" width="584" height="438" class="alignnone size-large wp-image-1256" /></a>

# Notes

- Since `test` service and `builder` service share same build cache via docker named volume, there's no overhead to download/install dependency for each deployment.
- Thanks to new feature of `docker-compose` (e.g. named volume, extends), I could put many logic in one `docker-compose.yml` file.
- All `docker-compose` commands are wrapped with [`Makefile`](https://github.com/hi-ogawa/yesod-experiment/blob/master/Makefile).

# Improvements

- use _stack_ instead of directly dealing with _cabal_
- put _docker-compose services_ (below steps) into automated pipeline (e.g. self-hosted Jenkins or other cloud services)
  - run `test` service
  - run `builder` service
  - build `distributor` service
  - push production image to repository

# References

- https://blog.codeship.com/continuous-integration-and-delivery-with-docker/
  - I learned `builder`, `distributor` separation from this article
- https://devcenter.heroku.com/articles/container-registry-and-runtime
  - this page explains heroku specific container runtime environment. you must/should read `$PORT` and `$DATABASE_URL` on runtime.