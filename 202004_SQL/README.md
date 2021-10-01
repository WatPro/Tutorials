
## Check Database Version in Use

### MySQL / MariaDB

```SQL
SHOW VARIABLES WHERE `Variable_name` = 'version';
SHOW VARIABLES LIKE 'version%';

```

Link: [MySQL Reference Manual](https://dev.mysql.com/doc/refman/8.0/en/show-variables.html "13.7.7.41 SHOW VARIABLES Statement")

### Transact-SQL

```SQL
SELECT @@VERSION AS [SQL_Server_Version];

```

Link: [Transact-SQL (T-SQL) Reference](https://docs.microsoft.com/en-us/sql/t-sql/functions/version-transact-sql-configuration-functions "@@VERSION - Transact SQL Configuration Functions")

### Oracle PL/SQL

```SQL
SELECT * FROM PRODUCT_COMPONENT_VERSION;

```

Link: [Database Administrator's Guide](https://docs.oracle.com/cd/B28359_01/server.111/b28310/dba004.htm "Identifying Your Oracle Database Software Release")

