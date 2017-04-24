<!--
{
  "title": "Database Architecture",
  "date": "2017-04-13T11:32:44+09:00",
  "category": "",
  "tags": [ "database", "mariadb" ],
  "draft": true
}
-->

# Original motivation

> When you change a data type using CHANGE or MODIFY, MySQL tries to convert existing column values to the new type as well as possible.

The semantics for `ALTER TABLE tabl_name MODIFY col_name column_definition` ([reference](https://dev.mysql.com/doc/refman/5.7/en/alter-table.html))
is actually undefined. Let's go for understanding what's happening under the hood.

# Architecture

- server (tcp)
- client library (tcp)
- application level client
  - connection pooling

# Reference

- https://mariadb.org/get-involved/getting-started-for-developers/
- some book out there ?
