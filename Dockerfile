FROM debian:jessie

MAINTAINER DNX DragoN "ratthee.jar@hotmail.com"

ENV NGINX_VERSION 1.10.1-1~jessie
ENV php_conf /etc/php5/fpm/php.ini
ENV fpm_conf /etc/php5/fpm/php-fpm.conf
ENV composer_hash e115a8dc7871f15d853148a7fbac7da27d6c0030b848d9b3dc09e2a0388afed865e6a3d6b3c0fad45c48e2b5fc1196ae

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
	&& echo "deb http://nginx.org/packages/debian/ jessie nginx" >> /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y \
						ca-certificates \
						nginx=${NGINX_VERSION} \
						nginx-module-xslt \
						nginx-module-geoip \
						nginx-module-image-filter \
						nginx-module-perl \
						nginx-module-njs \
						gettext-base \
                        autoconf \
                        file \
                        g++ \
                        gcc \
                        libc-dev \
                        make \
                        pkg-config \
                        re2c \
                        ca-certificates \
                        curl \
                        libedit2 \
                        libsqlite3-0 \
                        libxml2 \
                        xz-utils \
                        git \
                        wget

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

RUN apt-get install -y php5 php5-fpm php5-mysql php5-cli php5-mysql \
            php5-mcrypt \
            php5-gd \
            php5-intl \
            php5-memcache \
            php5-pgsql \
            php5-xsl \
            php5-curl \
            php5-json \
            && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '${composer_hash}') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"

ADD ./scripts/mysql-setup.sh /tmp/mysql-setup.sh
RUN /bin/sh /tmp/mysql-setup.sh

# copy in code
ADD src/ /var/www/html/
ADD errors/ /var/www/errors/

EXPOSE 80 443 3306

CMD ["nginx", "-g", "daemon off;"]