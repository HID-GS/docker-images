#!/usr/bin/env sh
cd /etc/nginx/conf.d

##### common variables
semaphore="status_semaphore.run"
status_root="status_host"
status_file="${status_root}.$(hostname)"

##### common functions START #####

# Common log function
log_text() {
  now=$(date "+%Y/%m/%d %H:%M:%S")
  echo "$now - $(hostname) - $@"
}

# Flag restart of all running nginx instances
flag_restart() {
  ls ${status_root}.* 2> /dev/null | while read file; do
    echo "$@" >> $file
    log_text "Restart flagged - $@"
  done
}

# Flag restart of only this running nginx instance
flag_restart_single() {
  echo "$@" >> ${status_file}
  log_text "Restart single flagged - $@"
}

# Delete old configs that no longer have template files
delete_old_configs() {
  find . -type f -name '*.conf' | while read file; do
    if [ ! -f $file.tpl ]; then
      log_text "Removing templateless configuration $file"
      rm $file
      flag_restart "Removed $file"
    fi
  done
}

# Generate new configs from templates
generate_configs() {
  touch_status_file
  if [ ! -f ${semaphore} ]; then
    semaphore_start
    delete_old_configs

    ls *.conf.tpl 2> /dev/null | while read template; do
    
      # Setup basic control variables
      config=${template%.tpl}

      if [ "${config:0:5}" == "host." ]; then
        host=${config:5}
        host=${host%.conf}
        ping -c 1 $host &> /dev/null
        if [ $? -eq 0 ]; then
          if [ ! -f $config ]; then
            log_text "Detected new working host $host, adding it to nginx"
            cp $template $config
            flag_restart "host up $config"
          else
            diff $config $template &> /dev/null
            if [ $? -ne 0 ]; then
              log_text "Detected configuration changes on $host, will tell nginx to restart"
              cp $template $config
              flag_restart "Change in $config"
            fi
          fi
        elif [ -f $config ]; then
          log_text "Detected failed host $host, removing it from nginx"
          rm $config
          flag_restart "Host down $host"
        fi
      elif [ ! -f $config ]; then
        log_text "Detected new configuration $config, enabling it" 
        cp $template $config
        flag_restart "New $config"
      else
        diff $config $template &> /dev/null
        if [ $? -ne 0 ]; then
          log_text "Detected configuration changes on $config, will tell nginx to restart"
          cp $template $config
          flag_restart "Change in $config"
        fi
      fi

    done
    semaphore_stop
  else
    while [ $(ls 2> /dev/null | grep ${semaphore} | wc -l) -gt 0 ]; do
      log_text "Semaphore file detected, waiting for it to go away before continuing"
      sleep 5
    done
    log_text "Semaphore file is gone, proceeding..."
  fi
  
  # If nginx is not running, start it & reset the status file
  pidof nginx > /dev/null
  if [ $? -ne 0 ]; then
    # start nginx
    nginx
    # reset status file
    > ${status_file}
  # If a restart is flagged, restart nginx
  elif [ $(cat ${status_file} | wc -l) -gt 0 ]; then
    log_text 'Changes detected, reloading nginx'
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
    if [ $(ls ${status_root}.* 2> /dev/null | wc -l ) -gt 0 ]; then
      find ./${status_root}* -mtime +1 | while read status; do
        log_text "Cleaning up old status file - $status"
        rm $status
      done
    fi
  fi

  # Create and touch ours
  if [ ! -f ${status_file} ]; then
    # flag restart on new file
    flag_restart_single "Creating new ${status_file}"
  fi
  touch ${status_file}
}

##### common functions END   #####

# stagger process between multiple servers
sleep $(echo "$RANDOM/10000" | bc -l)
log_text "Starting nginx"

# Monitor files for changes
while [ 1 -eq 1 ]; do

  # create control variable
  generate_configs

  sleep 60
  log_text "Rechecking nginx stanzas"

done
