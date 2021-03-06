FROM nginx:stable

MAINTAINER DNX DragoN "ratthee.jar@hotmail.com"

ENV php_conf /etc/php5/fpm/php.ini
ENV fpm_conf /etc/php5/fpm/php-fpm.conf
ENV MYSQLPASS password
	
RUN apt-get update && apt-get install -y nano curl php5-fpm php5-mysql php5-mcrypt php5-gd php5-intl php5-memcache php5-xsl php5-curl php5-json \
	&& rm -rf /var/lib/apt/lists/*
	
# tweak php-fpm config
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" ${php_conf} && \
sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" ${php_conf} && \
sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" ${php_conf} && \
sed -i -e "s/variables_order = \"GPCS\"/variables_order = \"EGPCS\"/g" ${php_conf} && \
sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" ${fpm_conf} && \
sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" ${fpm_conf} && \
sed -i -e "s/pm.max_children = 4/pm.max_children = 4/g" ${fpm_conf} && \
sed -i -e "s/pm.start_servers = 2/pm.start_servers = 3/g" ${fpm_conf} && \
sed -i -e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" ${fpm_conf} && \
sed -i -e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" ${fpm_conf} && \
sed -i -e "s/pm.max_requests = 500/pm.max_requests = 200/g" ${fpm_conf} && \
sed -i -e "s/user = nobody/user = nginx/g" ${fpm_conf} && \
sed -i -e "s/group = nobody/group = nginx/g" ${fpm_conf} && \
sed -i -e "s/;listen.mode = 0660/listen.mode = 0666/g" ${fpm_conf} && \
sed -i -e "s/;listen.owner = nobody/listen.owner = nginx/g" ${fpm_conf} && \
sed -i -e "s/;listen.group = nobody/listen.group = nginx/g" ${fpm_conf} && \
sed -i -e "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g" ${fpm_conf} &&\
sed -i -e "s/^;clear_env = no$/clear_env = no/" ${fpm_conf};

# Copy our nginx config
RUN rm -Rf /etc/nginx/nginx.conf
ADD conf/nginx.conf /etc/nginx/nginx.conf
RUN rm -Rf /etc/nginx/conf.d/default.conf
ADD conf/nginx-site.conf /etc/nginx/conf.d/default.conf

# copy in code
ADD src/ /usr/share/nginx/html/
ADD errors/ /usr/share/nginx/errors/

RUN apt-get update && apt-get install -y software-properties-common \
&& rm -rf /var/lib/apt/lists/*

RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db \
&& add-apt-repository 'deb [arch=amd64,i386] http://mirrors.accretive-networks.net/mariadb/repo/10.1/debian jessie main'

RUN echo mariadb-server-10.1 mysql-server/root_password password $MYSQLPASS | debconf-set-selections;\
echo mariadb-server-10.1 mysql-server/root_password_again password $MYSQLPASS | debconf-set-selections;

RUN apt-get update \
&& apt-get install -y mariadb-server supervisor \
&& rm -rf /var/lib/apt/lists/*

RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

RUN /usr/bin/mysqld_safe & sleep 10s \
&& echo "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' IDENTIFIED BY 'password' WITH GRANT OPTION;FLUSH PRIVILEGES;" | mysql -uroot -p$MYSQLPASS

# Add Scripts
ADD scripts/start.sh /start.sh

COPY conf/supervisord.conf /etc/supervisord.conf

EXPOSE 80 443 3306

#CMD ["/start.sh"]
#CMD ["/bin/bash"]
CMD [ "/bin/bash", "/start.sh", "start" ]