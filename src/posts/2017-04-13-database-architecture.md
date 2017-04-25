<!--
{
  "title": "Database Architecture (MySQL)",
  "date": "2017-04-13T11:32:44+09:00",
  "category": "",
  "tags": [ "database", "mariadb", "mysql" ],
  "draft": true
}
-->

# Build from source

```
$ mkdir -p out/Default/_install
$ cd out/Default
$ cmake -G Ninja ../.. -DCMAKE_INSTALL_PREFIX=$PWD/_install
$ ninja -j 2 install
$ ninja -t browse --port=8989 # it's good to see dependency since it shows separation of components
```

Running mysql server out of tree

```
$ cd out/Default/_install

# Check configuration
$ ./bin/mysqld --verbose --help

# Setup system tables necessary to play with server
$ ./scripts/mysql_install_db --datadir=$PWD/data

# Run server with minimal option
# --no-defaults: not read default .cnf files
# --datadir: put storage data out of tree
$ ./bin/mysqld --no-defaults --datadir=$PWD/data --port=6789

# Run client from another shell
$ ./bin/mysql -u root --password='asdfjkl;' --port=6789
> CREATE DATABASE db1;
> CREATE TABLE `db1`.`t1` (`id` INT, `num` INT);
> INSERT INTO `db1`.`t1` (`id`, `num`) VALUES (0, 123);
> SELECT * FROM `db1`.`t1`;
MariaDB [(none)]> select * from `db1`.`t1`;
+------+------+
| id   | num  |
+------+------+
|    0 |  123 |
+------+------+
1 row in set (0.00 sec)
> UPDATE `db1`.`t1` SET `num` = 456 WHERE `id` = 0;
> SELECT * FROM `db1`.`t1`;
+------+------+
| id   | num  |
+------+------+
|    0 |  456 |
+------+------+
1 row in set (0.00 sec)
> DELETE FROM `db1`.`t1` WHERE `id` = 0;
> SELECT * FROM `db1`.`t1`;
Empty set (0.00 sec)
```


# Follow basic flow

- database creation
- table creation
- row insert/update/delete


# Configuration

```
$ out/Default_install/bin/mysqld --no-defaults --verbose --help # list available options
```


# TODO

- server (tcp)
- master-slave  
- sql implementation
- data structure/layout in storage and in memory
- transaciton
- replication
- plugin architecture
- authentication and priviledge system
- client library (tcp)
- application level client
  - connection pooling


# Reference

- https://github.com/MariaDB/server
- [Understanding MySQL Internals]()
- https://mariadb.com/kb/en/mariadb/documentation/
