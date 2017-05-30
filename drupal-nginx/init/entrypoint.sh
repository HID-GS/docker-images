#!/usr/bin/env sh
mkdir -p /etc/nginx/sites-available
envsubst '${NGINX_SERVER_ROOT}' < /etc/nginx/templates/default.conf.template > /etc/nginx/sites-available/default.conf
nginx