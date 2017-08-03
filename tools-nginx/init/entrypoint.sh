#!/usr/bin/env sh
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
nginx

while [ 1 -eq 1]; do

  read -t 60

  restart=0

  ls *.conf.tpl | while read template; do
    config=$(echo $template | sed 's/.tpl//g')
    host=$(echo $template | sed 's/.conf.tpl//g')
    ping -c 1 $host &> /dev/null
    if [ $? -eq 1 ]; then
      if [ !-f $config ]; then
        cp $template $config
        restart=1
      fi
    else
      if [ -f $config ]; then
        rm $config
        restart=1
      fi
    fi
  done

  if [ $restart -eq 1 ]; then
    #restart nginx
    nginx -s reload
  fi

done