#!/bin/bash

echo "docker username set"
DOCKER_USERNAME=$1
echo "docker password set"
DOCKER_PASSWORD=$2
echo "registry name set"
REGISTRY_NAME=$3
echo "registry image set"
REGISTRY_IMAGE=$4
echo "registry tag set"
REGISTRY_TAG=$5

if [ -z "$DOCKER_USERNAME" ]
then
      echo "\$DOCKER_USERNAME is empty"
      exit 1
fi

if [ -z "$DOCKER_PASSWORD" ]
then
      echo "\$DOCKER_PASSWORD is empty"
      exit 1
fi

if [ -z "$REGISTRY_NAME" ]
then
      echo "\$REGISTRY_NAME is empty"
      exit 1
fi

if [ -z "$REGISTRY_IMAGE" ]
then
      echo "\$REGISTRY_IMAGE is empty"
      exit 1
fi

if [ -z "$REGISTRY_TAG" ]
then
      echo "\$REGISTRY_TAG is empty"
      exit 1
fi

# If there is an unknown 8th variable then exit

if [ -n "$6" ]
then
      echo "Too many arguments"
      exit 1
fi

# Update and install nginx

sudo apt-get update -y
sudo apt-get install docker-compose -y
sudo apt-get install nginx -y

# Setup firewall

sudo ufw allow OpenSSH
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 'Nginx HTTP'
sudo ufw allow 'Nginx HTTPS'
sudo ufw --force enable

sed -i "s/REGISTRY_NAME/$REGISTRY_NAME/g" docker-compose.yml
sed -i "s/REGISTRY_IMAGE/$REGISTRY_IMAGE/g" docker-compose.yml
sed -i "s/REGISTRY_TAG/$REGISTRY_TAG/g" docker-compose.yml

# Copy nginx config

cp nginx/nginx.conf /etc/nginx/nginx.conf
cp nginx/sites-available/default /etc/nginx/sites-available/default

# Restart nginx

sudo systemctl restart nginx

# Login to docker

docker stop $(docker ps -a -q) && docker rm $(docker ps -a -q) && docker rmi $(docker images -q)
sudo echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin registry.digitalocean.com

# Write out current crontab

crontab -l > tmpcron

# Echo new cron into cron file

echo "0 3 * * * /usr/bin/docker system prune -f" >> tmpcron

#install new cron file

crontab tmpcron
rm tmpcron

docker-compose up -d