#!/bin/bash

service nginx start
service php5-fpm start
service mysql start

trap 'exit 0' SIGTERM
while true; do :; done