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
          libjpeg-turbo-dev \
          libpng-dev \
    && docker-php-ext-install -j$(nproc) iconv mbstring opcache pdo pdo_mysql sockets zip \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

RUN pecl install imagick redis \
    && docker-php-ext-enable imagick redis \
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
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini

WORKDIR /var/www/html
EXPOSE 9000
CMD ["php-fpm"]