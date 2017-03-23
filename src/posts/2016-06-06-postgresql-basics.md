<!--
{
  "title": "Postgresql Basics",
  "date": "2016-06-06T00:12:25.000Z",
  "category": "",
  "tags": [
    "postgresql"
  ],
  "draft": true
}
-->

---

### Mac OS Specific Tricks

If you did `brew install postgres`, your postgresql server doesn't accept non-local connection by defaut. So, I changed config files as follows:

_/usr/local/var/postgres/postgresql.conf_

```
## before ## 

listen_addresses = &#039;localhost&#039;


## after ##

listen_addresses = &#039;*&#039;
```

_/usr/local/var/postgres/pg_hba.conf_

```
## before ##

local   all             all                                     trust
host    all             all             127.0.0.1/32            trust
host    all             all             ::1/128                 trust

## after ##

local   all             all                                     trust
host    all             all             all                     trust
```

Then, restart postgresql with the below command:

```
$ pg_ctl restart -D /usr/local/var/postgres
```

- create special user "postgres"

```
# create user postgres;
# alter user postgres password &#039;postgres&#039;;
```

---

### Basic `psql` commands:

```
-- login --
$ psql -h localhost -U hiogawa postgres

-- turn off pager --
# \pset pager off

-- show users --
# select * from pg_user;

-- show databases --
# select * from pg_database;
# \l

-- switch databases --
# \connect dbname

-- show tables --
# \dt

-- show help --
# \h select
# \h drop user
```

```
-- admin --
$ sudo su - postgres
$ psql
```


### References

- https://github.com/thuss/standalone-migrations
- SQL DSL: http://api.rubyonrails.org/classes/ActiveRecord/Migration.html
- http://stackoverflow.com/questions/7975556/how-to-start-postgresql-server-on-mac-os-x#answer-7975660
- http://www.postgresql.org/docs/8.0/static/user-manag.html
- http://stackoverflow.com/questions/9604723/alternate-output-format-for-psql
- http://www.uptimemadeeasy.com/databases/navigating-postgresql-with-psql-command-line/