#!/bin/bash

echo "Enter docker username:"
read docker_username
echo "Enter docker password:"
read docker_password
echo "Enter registry name:"
read registry_name
echo "Enter registry image:"
read registry_image
echo "Enter registry tag:"
read registry_tag

sudo bash init.sh $docker_username $docker_password $registry_name $registry_image $registry_tag