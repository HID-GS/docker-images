#!/usr/bin/env bash
cd /etc/nginx/conf.d
# Delete old configs
find . -type f -name '*.conf' -delete
# Generate new configs from templates
for file in {.,}*;
do
  if ping -c 1 ${file%.conf.*} &> /dev/null
	then
    cp ${file} ${file%.tpl}
	fi
done
# Start nginx
nginx -g "daemon off;"