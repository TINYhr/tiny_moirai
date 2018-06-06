#!/bin/bash
#

  mod=`date -r ./cache/${file_name} +%s`
  now=`date +%s`
  days=$(expr \( $now - $mod \) / 86400)

get_user_name () {
  echo "$1" | sed -e 's/.*\///g' | sed -e 's/\.pub//g'
}

# Remove user accounts whose public key was deleted from S3
if [ -f ~/keys_installed ]; then
  while read line; do
    USER_NAME="`get_user_name "$line"`"
    echo "[`date --date="today" "+%Y-%m-%d %H-%M-%S"`][$USER_NAME]: Removing user account"

    if [ -f /home/${USER_NAME}/.INACTIVE ]; then
      mod=`date -r /home/${USER_NAME}/.INACTIVE +%s`
      now=`date +%s`
      hours=$(expr \( $now - $mod \) / 2073600)

      echo "[`date --date="today" "+%Y-%m-%d %H-%M-%S"`][$USER_NAME]: Last activity at `date -r /home/${USER_NAME}/.INACTIVE`."
      if [ $hours > 1 ]; then
        /usr/sbin/userdel -r -f $USER_NAME
        echo "[`date --date="today" "+%Y-%m-%d %H-%M-%S"`][$USER_NAME]: Removed user account."
      fi
    fi
  done < ~/keys_installed
fi
