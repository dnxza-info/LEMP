#!/bin/bash

service php5-fpm start
service mysql start

nginx -g "daemon off;"