FROM php:7.1-fpm-alpine
RUN apk update \
		&& apk upgrade \
    && apk add --no-cache --virtual .build-deps \
    	    autoconf \
    		  build-base \
    		  coreutils \
    		  freetype-dev \
    		  libtool \
    		  pcre-dev \
    && apk add --no-cache \
          imagemagick-dev \
          libexif-dev \
          libjpeg-turbo-dev \
          libmcrypt-dev \
          libpng-dev \
          librsvg-dev \
          libxslt-dev \
    && docker-php-ext-install -j$(nproc) exif iconv mbstring mcrypt opcache pdo pdo_mysql sockets zip xsl\
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN pecl install imagick redis xdebug \
    && docker-php-ext-enable imagick redis xdebug \
    && apk del .build-deps
# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini; \
    { \
        echo 'catch_workers_output = yes;'; \
        echo 'display_errors=on;'; \
        echo 'display_startup_errors=on;'; \
        echo 'error_log=/var/log/fpm-php.www.log;'; \
        echo 'log_errors=on;'; \
        echo 'listen=0.0.0.0:9000;'; \
        echo 'memory_limit=512M;'; \
        echo 'post_max_size=100M;' \
        echo 'upload_max_filesize=100M'; \
        echo 'upload_tmp_dir=/tmp'; \
    } > /usr/local/etc/php/conf.d/logs.ini; \
    touch /var/log/fpm-php.www.log && chmod 777 /var/log/fpm-php.www.log

WORKDIR /var/www
EXPOSE 9000
CMD ["php-fpm"]
