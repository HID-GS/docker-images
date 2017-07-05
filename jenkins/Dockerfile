FROM jenkinsci/jenkins:alpine
USER root
RUN apk update && apk upgrade && apk add --update --no-cache \
		docker \
		openrc \
		php7 \
		php7-ctype \
		php7-dom \
		php7-fpm \
		php7-json \
		php7-iconv \
		php7-mbstring \
		php7-openssl \
		php7-pdo \
		php7-pear \
		php7-phar \
		php7-xdebug \
		php7-xml \
		php7-zip \
		php7-zlib && \
		ln -s /usr/bin/php7 /usr/bin/php
RUN { \
				echo 'zend_extension=xdebug.so'; \
				echo 'xdebug.force_display_errors=1'; \
				echo 'xdebug.force_error_reporting=1'; \
				echo 'xdebug.show_error_trace=1' \
		} > /etc/php7/conf.d/xdebug.ini && \
		{ \
				echo 'opcache.enable=1'; \
				echo 'display_errors=1'; \
				echo 'display_startup_errors=1'; \
				echo 'error_log=/var/log/php_errors.log'; \
				echo 'log_errors=1'; \
				echo 'error_reporting=E_ALL'; \
		} > /etc/php7/conf.d/development.ini
RUN rc-update add docker boot
RUN php7 -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
		php7 -r "if (hash_file('SHA384', 'composer-setup.php') === \
		'669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') \
		{ echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
		php7 composer-setup.php && \
		php7 -r "unlink('composer-setup.php');" && \
		mv composer.phar  /usr/local/bin/composer
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
