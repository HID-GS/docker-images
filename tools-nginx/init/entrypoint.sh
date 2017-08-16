#!/usr/bin/env sh
cd /etc/nginx/conf.d

# stagger process between multiple servers
sleep $(bc -l <<< "$RANDOM/10000")

##### common functions START #####

# Common log function
log_text() {
  now=$(date "+%Y/%m/%d %H:%M:%S")
  echo "$now - $@"
}

# Delete old configs that no longer have template files
delete_old_configs() {
  find . -type f -name '*.conf' | while read file; do
    if [ ! -f $file.tpl ]; then
      log_text "Removing templateless configuration $file"
      rm $file
    fi
  done
}

# Generate new configs from templates
generate_configs() {
  delete_old_configs

  ls *.conf.tpl | while read template; do
  
    # Setup basic control variables
    config=${template%.tpl}

    if [ "${template:0:5}" == "host." ]; then
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
    fi

    # If a restart is flagged, restart nginx
    if [ $restart -eq 1 ]; then
      echo 'changes detected, reloading nginx'
      #restart nginx
      nginx -s reload
      restart=0
    fi

  done

  for file in $(ls *.conf.tpl); do
    # if this is a host definition RP, check it
    if [ "${file:0:5}" == "host." ]; then
      host=${file:5}
      host=${host%.conf.tpl}
      ping -c 1 ${host} &> /dev/null
      if [ $? -eq 0 ]; then
        echo "found ${host}"
        cp ${file} ${file%.tpl}
      else
        echo "${file%conf.*} not found"
      fi
    fi
  done
  log_text "Done generating config files"
}

##### common functions END   #####



# Start nginx
nginx


# Monitor files for changes
while [ 1 -eq 1 ]; do

  sleep 60

  echo "rechecking nginx stanzas"

  # create control variable
  restart=0

done
