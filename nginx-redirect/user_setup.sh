#!/bin/bash

echo "Enter domain name:"
read domain_name
echo "Enter email for domain updates:"
read domain_email
echo "Enter domain to redirect to:"
read domain_redirect

sudo bash init.sh $domain_name $domain_email $domain_redirect