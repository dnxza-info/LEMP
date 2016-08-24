#!/bin/bash

#service nginx start
#service php5-fpm start

if [ ! -f /var/lib/mysql/ibdata1 ]; then

	mysql_install_db

	/usr/bin/mysqld_safe &
	sleep 10s

	echo "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;FLUSH PRIVILEGES;" | mysql

	killall mysqld
	sleep 10s
fi

#/usr/bin/mysqld_safe

# Start supervisord and services
/usr/bin/supervisord -n -c /etc/supervisord.conf

trap 'exit 0' SIGTERM
while true; do :; done