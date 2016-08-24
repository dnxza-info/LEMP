#!/bin/bash

#service nginx start
#service php5-fpm start
#/usr/bin/mysqld_safe

# Start supervisord and services
/usr/bin/supervisord -n -c /etc/supervisord.conf