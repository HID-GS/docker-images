#!/usr/bin/env sh
cd /etc/nginx/conf.d

##### common variables
semaphore="status_semaphore"
status_root="status_host"
status_file="${status_root}_$(hostname)"

##### common functions START #####

# Common log function
log_text() {
  now=$(date "+%Y/%m/%d %H:%M:%S")
  echo "$now - $(hostname) - $@"
}

# Flag restart of all running nginx instances
flag_restart() {
  ls ${status_root}_* | while read file; do
    echo "$@" >> $file
    log_text "Restart flagged - $@"
  done
}

# Delete old configs that no longer have template files
delete_old_configs() {
  find . -type f -name '*.conf' | while read file; do
    if [ ! -f $file.tpl ]; then
      log_text "Removing templateless configuration $file"
      rm $file
      flag_restart "removed $config"
    fi
  done
}

# Generate new configs from templates
generate_configs() {
  touch_status_file
  if [ ! -f ${semaphore} ]; then
    semaphore_start
    delete_old_configs

    ls *.conf.tpl | while read template; do
    
      # Setup basic control variables
      config=${template%.tpl}

      if [ "${config:0:5}" == "host." ]; then
        host=${config:5}
        ping -c 1 $host &> /dev/null
        if [ $? -eq 0 ]; then
          if [ ! -f $config ]; then
            log_text "detected new working host $host, adding it to nginx"
            cp $template $config
            flag_restart "host up $config"
          else
            diff $config $template &> /dev/null
            if [ $? -ne 0 ]; then
              log_text "detected configuration changes on $host, will tell nginx to restart"
              cp $template $config
              flag_restart "change in $config"
            fi
          fi
        else
          if [ -f $config ]; then
            log_text "detected failed host $host, removing it from nginx"
            rm $config
            flag_restart "host down $config"
          fi
        fi
      else
        if [ ! -f $config ]; then
          log_text "detected new configuration $config, enabling it" 
          cp $template $config
          flag_restart "new $config"
        else
          diff $config $template &> /dev/null
          if [ $? -ne 0 ]; then
            log_text "detected configuration changes on $config, will tell nginx to restart"
            cp $template $config
            flag_restart "change in $config"
          fi
        fi
      fi

    done
    semaphore_stop
  else
    while [ -f ${semaphore} ]; do
      log_text "semaphore file detected, waiting of it to go away before"
      sleep 5
    done
    log_text "semaphore file is gone, proceeding..."
  fi

  # If a restart is flagged, restart nginx
  if [ $(cat ${status_file} | wc -l) -gt 0 ]; then
    echo 'changes detected, reloading nginx'
    #restart nginx
    nginx -s reload
    # reset status file
    > ${status_file}
  fi
}

# Create semaphore file
semaphore_start() {
  if [ ! -f ${semaphore} ]; then
    log_text "Creating semaphore file ${semaphore}"
    echo $(hostname) >> ${semaphore}
  fi
}

# Remove semaphore file
semaphore_stop() {
  if [ -f ${semaphore} ]; then
    log_text "Deleting semaphore file ${semaphore}"
    rm ${semaphore}
  fi
}

# Upkeep of status file
touch_status_file() {

  # Clean up old files
  if [ ! -f ${semaphore} ]; then
    if [ -f ${status_root}_* ]; then
      find ./${status_root}* -mtime +1 | while read status; do
        log_text "Cleaning up old status file - $status"
        rm $status
      done
    fi
  fi

  # Create and touch ours
  if [ ! -f ${status_file}]; then
    log_text "Creating ${status_file}"
  fi
  touch ${status_file}
}

##### common functions END   #####

# stagger process between multiple servers
sleep $(bc -l <<< "$RANDOM/10000")
log_text "Starting nginx"

# Start nginx
nginx

touch_status_file

# Monitor files for changes
while [ 1 -eq 1 ]; do

  sleep 60

  log_text "rechecking nginx stanzas"

  # create control variable
  generate_configs

done
