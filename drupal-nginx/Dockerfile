FROM nginx:alpine

ADD nginx.conf /etc/nginx/
COPY sites/*.conf.template /etc/nginx/templates/
COPY init/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ARG PHP_UPSTREAM=php
ENV NGINX_SERVER_ROOT=/var/www/html

RUN apk update \
    && apk upgrade \
    && apk add --no-cache bash \
    && addgroup -g 48 -S www-data \
    && adduser -G www-data -D -H -u 48 -s /bin/bash www-data \
    && rm /etc/nginx/conf.d/default.conf \
    && echo "upstream php-upstream { server ${PHP_UPSTREAM}:9000; }" > /etc/nginx/conf.d/upstream.conf

ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 80 443
