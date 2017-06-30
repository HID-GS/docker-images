FROM jenkinsci/jenkins:alpine
USER root
RUN apk update && apk add --update --no-cache \
		php7 \
		php7-ctype \
		php7-dom \
		php7-fpm \
		php7-json \
		php7-iconv \
		php7-mbstring \
		php7-openssl \
		php7-pdo \
		php7-phar \
		php7-zip \
		php7-zlib && \
		ln -s /usr/bin/php7 /usr/bin/php
RUN php7 -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
		php7 -r "if (hash_file('SHA384', 'composer-setup.php') === \
		'669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') \
		{ echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
		php7 composer-setup.php && \
		php7 -r "unlink('composer-setup.php');" && \
		mv composer.phar  /usr/local/bin/composer
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
