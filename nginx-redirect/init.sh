#!/bin/bash

echo "domain name set"
DOMAIN_NAME=$1
echo "email for domain updates set"
DOMAIN_EMAIL=$2
echo "domain redirect set"
DOMAIN_REDIRECT=$3

if [ -z "$DOMAIN_NAME" ]
then
      echo "\$DOMAIN_NAME is empty"
      exit 1
fi

if [ -z "$DOMAIN_EMAIL" ]
then
      echo "\$DOMAIN_EMAIL is empty"
      exit 1
fi

if [ -z "$DOMAIN_REDIRECT" ]
then
      echo "\$DOMAIN_REDIRECT is empty"
      exit 1
fi

# If there is an unknown 4th variable then exit

if [ -n "$4" ]
then
      echo "Too many arguments"
      exit 1
fi

# Update and install nginx

sudo apt-get update -y
sudo apt-get install nginx -y

# Setup firewall

sudo ufw allow OpenSSH
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 'Nginx HTTP'
sudo ufw allow 'Nginx HTTPS'
sudo ufw --force enable

# Replace config text

sed -i "s/DOMAIN_NAME/$DOMAIN_NAME/g" nginx/sites-available/default
sed -i "s/DOMAIN_REDIRECT/$DOMAIN_REDIRECT/g" nginx/sites-available/default

# Copy nginx config

cp nginx/nginx.conf /etc/nginx/nginx.conf
cp nginx/sites-available/default /etc/nginx/sites-available/default

# Setup SSL certs

snap install certbot --classic
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot --nginx --non-interactive --agree-tos -m $DOMAIN_EMAIL -d $DOMAIN_NAME -d www.$DOMAIN_NAME --register-unsafely-without-email
sudo certbot renew --dry-run

# Restart nginx

sudo systemctl restart nginx
