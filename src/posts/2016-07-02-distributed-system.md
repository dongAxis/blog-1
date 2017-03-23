<!--
{
  "title": "Distributed system",
  "date": "2016-07-02T15:52:53.000Z",
  "category": "",
  "tags": [
    "ops",
    "database",
    "distributed-system"
  ],
  "draft": false
}
-->

# Experiments

- Database Clustering: https://github.com/hi-ogawa/database_cluster
- etcd: https://github.com/hi-ogawa/etcd_experiment

# Reference

- Basic Concept: CAP, ACID, BASE
  - https://www.infoq.com/articles/cap-twelve-years-later-how-the-rules-have-changed

- Algolia case study:
  - http://highscalability.com/blog/2015/3/9/the-architecture-of-algolias-distributed-search-network.html
  - https://blog.algolia.com/inside-the-algolia-engine-part-1-indexing-vs-search/
  - https://medium.com/@algolia/algolia-s-fury-road-to-a-worldwide-api-c1536c46f3a5#.3ig3j3ves

- PostgreSQL:
  - https://www.postgresql.org/docs/9.5/static/high-availability.html
  - https://www.digitalocean.com/community/tutorials/how-to-set-up-master-slave-replication-on-postgresql-on-an-ubuntu-12-04-vps 
  - https://cloud.google.com/solutions/setup-postgres-hot-standby

- MongoDB: https://docs.mongodb.com/manual/core/replication-introduction/

# Reading RAFT Algorithm Paper (still reading)
  
- RAFT algorithm: https://raft.github.io/
- Paper: https://raft.github.io/raft.pdf

- kinds of failure
  - server crush (process died)
  - network failure (process can still run)
  - care after coming back
      - idempotency of RPC

- concern separation
  - leader failure
  - other roles failure

- is log execution asynchronous to cluster communication