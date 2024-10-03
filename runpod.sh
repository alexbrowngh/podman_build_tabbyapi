#!/usr/bin/env bash

set -o pipefail

echo "Pod started.."

if [[ $PUBLIC_KEY ]]
then
  echo "Setting up SSH authorized_keys..."
  mkdir -p ~/.ssh
  echo "$PUBLIC_KEY" >> ~/.ssh/authorized_keys
  chmod 700 -R ~/.ssh
  ssh-keygen -v -l -f ~/.ssh/authorized_keys
fi

echo "Regenerating SSH host keys.."
rm -f /etc/ssh/ssh_host_* && \
  ssh-keygen -A

for SSH_HOST_PUB_KEY in /etc/ssh/ssh_host_*.pub
do
  echo "Host key: $SSH_HOST_PUB_KEY"
  ssh-keygen -lf $SSH_HOST_PUB_KEY
done

echo -e "\nexport PATH=\$PATH:/app" >> /root/.bashrc
service ssh start

# Deactivate the normal start script and replace it
chmod -v 644 /app/start.sh
mv -v /app/start.sh /app/_start.sh
ln -sfv /app/restart.sh /app/start.sh

# Dowload the default config.yml to the persistent storage if DEFAULT_CONFIG_YML is set.
if [ -n "$DEFAULT_CONFIG_YML" ]; then
    # Download the .yml file
    wget "$DEFAULT_CONFIG_YML" -O /tmp/downloaded_config.yml

    # Move and overwrite the config file
    mv -f /tmp/downloaded_config.yml /app/models/config.yml

    # Download the model using model_downloader.sh
    model_name=$(awk '/^model:/{f=1} f&&/model_name:/{print $2; exit}' /app/models/config.yml | tr -d '\r')
    /app/model_downloader.sh "$model_name"

    # Download the draft model using model_downloader.sh
    draft_model_name=$(awk '/^draft_model:/{f=1} f&&/draft_model_name:/{print $2; exit}' /app/models/config.yml | tr -d '\r')
    /app/model_downloader.sh "$draft_model_name"
else
    # If DEFAULT_CONFIG_YML doesn't exist, use the built-in config file
    mv -v /app/config.yml /app/models
fi
ln -sfv /app/models/config.yml /app/config.yml

echo "Starting tabbyAPI..."
/app/restart.sh

sleep infinity

