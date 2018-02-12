FROM alpine:3.7

ENV COMPOSER_HOME /usr/local/bin
ENV PATH $PATH:${COMPOSER_HOME}/vendor/bin

RUN apk update && apk add --no-cache \
    curl \
    git \
    php7 \
    php7-ctype \
    php7-dom \
    php7-iconv \
    php7-json \
    php7-mbstring \
    php7-openssl \
    php7-phar \
    php7-simplexml \
    php7-tokenizer \
    php7-xml \
    php7-xmlwriter \
    php7-zlib \
    && curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir=${COMPOSER_HOME} --filename=composer \
    && composer global require drupal/coder \
    && composer global require phpmd/phpmd \
    && phpcs --config-set installed_paths ${COMPOSER_HOME}/vendor/drupal/coder/coder_sniffer

WORKDIR /app

CMD ["phpcs", "--standard=Drupal,DrupalPractice", "."]