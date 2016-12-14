#!/usr/bin/env bash

# Give time to database to boot up
sleep 10

# Import schema structure
if [ -e "pdns.sql" ]; then
	mysql --host=$DATABASE_PORT_3306_TCP_ADDR --user=$MYSQL_USER --password=$MYSQL_PASSWORD --database=$MYSQL_DATABASE < pdns.sql
	rm pdns.sql
	echo "Imported schema structured"
fi

/usr/sbin/pdns_server \
	--launch=gmysql --gmysql-host=$DATABASE_PORT_3306_TCP_ADDR --gmysql-user=$MYSQL_USER --gmysql-dbname=$MYSQL_DATABASE --gmysql-password=$MYSQL_PASSWORD \
	--webserver=yes --webserver-address=0.0.0.0 --webserver-port=80 \
	--api=yes --api-key=changeme
