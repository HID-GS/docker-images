#!/usr/bin/env sh
cd /etc/nginx/conf.d
# Delete old configs
find . -type f -name '*.conf' -delete
# Generate new configs from templates
for file in $(ls *.conf.tpl);
do
  ping -c 1 ${file%.conf.tpl} &> /dev/null
  if [ $? -eq 0 ]; then
    echo "found ${file%.conf.*}"
    cp ${file} ${file%.tpl}
  else
    echo "${file%conf.*} not found"
  fi
done
# Start nginx
nginx

# Get current time
current_time=$(date +%s)

# Monitor files for changes
while [ 1 -eq 1 ]; do

  sleep 60

  echo "rechecking nginx stanzas"

  restart=0

  ls *.conf.tpl | while read template; do
  
    # If the file is changed, flag a restart
    template_time=$(stat -c %Z $template)
    if [ $current_time -lt $template_time ]; then
      restart=1
      current_time=$(date +%s)
    fi
    
    # If a file is added or removed, flag a restart
    # If a host status changed, flag a restart
    config=$(echo $template | sed 's/.tpl//g')
    host=$(echo $template | sed 's/.conf.tpl//g')
    ping -c 1 $host &> /dev/null
    if [ $? -eq 0 ]; then
      if [ ! -f $config ]; then
        echo "detected new working host $host, adding it to nginx"
        cp $template $config
        restart=1
      else
        diff $config $template &> /dev/null
        if [ $? -ne 0 ]; then
          echo "detected configuration changes on $host, will tell nginx to restart"
          cp $template $config
          restart=1
        fi
      fi
    else
      if [ -f $config ]; then
        echo "detected failed host $host, removing it from nginx"
        rm $config
        restart=1
      fi
    fi
  done

  # If a restart is flagged, restart nginx
  if [ $restart -eq 1 ]; then
    echo 'changes detected, reloading nginx'
    #restart nginx
    nginx -s reload
  fi

done