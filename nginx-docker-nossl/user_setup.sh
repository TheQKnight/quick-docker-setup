#!/bin/bash

echo "Enter docker username:"
read docker_username
echo "Enter docker password:"
read docker_password
echo "Enter domain name:"
read domain_name
echo "Enter email for domain updates:"
read domain_email
echo "Enter registry name:"
read registry_name
echo "Enter registry image:"
read registry_image
echo "Enter registry tag:"
read registry_tag
echo "Enter custom header:"
read custom_header

sudo bash init.sh $docker_username $docker_password $domain_name $domain_email $registry_name $registry_image $registry_tag $custom_header