#!/bin/bash
#
USER_NAME=$1
PUBLIC_KEY=$2

# Make sure the user name is alphanumeric
if [[ "$USER_NAME" =~ ^[a-z][-a-z0-9]*$ ]]; then
  echo "[`date --date="today" "+%Y-%m-%d %H-%M-%S"`][${USER_NAME}]: Adding user"
  # Create a user account if it does not already exist
  cut -d: -f1 /etc/passwd | grep -qx $USER_NAME
  if [ $? -eq 1 ]; then
    echo "[`date --date="today" "+%Y-%m-%d %H-%M-%S"`][${USER_NAME}]: Creating user"
    /usr/sbin/useradd --user-group --create-home $USER_NAME && \
    /usr/sbin/usermod -G tpdev $USER_NAME && \
    mkdir -m 700 /home/$USER_NAME/.ssh && \
    chown $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh && \
    echo "$USER_NAME" >> ~/keys_installed && \
    echo "[`date --date="today" "+%Y-%m-%d %H-%M-%S"`][${USER_NAME}]: Created user"
  fi

  # Copy the public key from S3, if a user account was created from this key
  if [ -f ~/keys_installed ]; then
    grep -qx "$USER_NAME" ~/keys_installed
    if [ $? -eq 0 ]; then
      echo "[`date --date="today" "+%Y-%m-%d %H-%M-%S"`][${USER_NAME}]: Updating ssh public key"
      echo "$PUBLIC_KEY" >> sudo tee /home/$USER_NAME/.ssh/authorized_keys
      chmod 600 /home/$USER_NAME/.ssh/authorized_keys
      chown $USER_NAME:$USER_NAME /home/$USER_NAME/.ssh/authorized_keys
      echo "[`date --date="today" "+%Y-%m-%d %H-%M-%S"`][${USER_NAME}]: Updated ssh public key"
    fi
  fi

  # Update .netrc for heroku auth
  echo "[`date --date="today" "+%Y-%m-%d %H-%M-%S"`][${USER_NAME}]: Setting up heroku access"
  cp -f /etc/skel/.netrc /home/$USER_NAME/ && \
  chown $USER_NAME:$USER_NAME /home/$USER_NAME/.netrc && \
  chmod 500 /home/$USER_NAME/.netrc && \
  touch /home/$USER_NAME/.INACTIVE && \
  echo "[`date --date="today" "+%Y-%m-%d %H-%M-%S"`][${USER_NAME}]: Done!"
fi
