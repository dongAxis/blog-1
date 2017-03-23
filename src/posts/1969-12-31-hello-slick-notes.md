<!--
{
  "title": "Notes on Hello Slick",
  "date": "1969-12-31T15:00:00.000Z",
  "category": "",
  "tags": [
    "scala",
    "slick"
  ],
  "draft": true
}
-->

Things to note:


- how to see the raw sql command of table schema
 - DDL(Data Definition Language): https://msdn.microsoft.com/en-us/library/ff848799.aspx
 - how to see those in console,
 - and via test.
- how is joining table working
 - https://en.wikipedia.org/wiki/Foreign_key#Example
- how N+1 problem is avoided
- try to use other popular dbs (postgres is better)
- learn how macro is working (e.g. `TableQuery[...]`)
- why is it expensive to generate sql?
 - regarding `Compiled` sql.
- The instance of `slick.lifted.TableQuery` has `schema` and `+=` methods only when it's in `DBIO` kinds of context. These two screenshots below are from the ENSIME inspector result of `coffees`, which shows the difference of available methods in each situation.

![](https://hiogawa-blog.s3.amazonaws.com/2015/Nov/Screen_Shot_2015_11_24_at_21_29_04-1448368178480.png)
![](https://hiogawa-blog.s3.amazonaws.com/2015/Nov/Screen_Shot_2015_11_24_at_21_30_49-1448368281356.png)