# gdash-amq-2-timescaledb
Push messages into a timescaledb instance


## Database notes

Create the postgresql/timescaledb DB like so:

```$ su - postgres
$ psql
postgres=# create user gdash with encrypted password 'YOUR_PASSWORD_HERE';
CREATE ROLE
postgres=# create database gdash;
CREATE DATABASE
postgres=# grant all privileges on database gdash to gdash;
GRANT'''

