Small scripts for migrate contents from wordpress (wp.hiogawa.net).

```
$ npm install
$ source .env
$ node sql2json.js # produces {wp_posts,wp_term_relationships,wp_terms}.json
$ node json2md.js # produces <some-title>.md under src/posts
```
