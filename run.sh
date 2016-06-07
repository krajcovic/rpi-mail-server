#!/bin/bash

container_name=mail-server

# Check container exist.
container_id=$(docker ps -a -q -f name=${container_name})
echo "Container ID: " $container_id

if [ $container_name ]; then
	echo 'Stopping container'
	docker stop ${container_name}
	echo 'Removing container'
	docker rm $container_name
fi


docker run -d \
	-p 25:25 \
	--name=$container_name \
	-e "DOMAIN_NAME=krajcovic.info" \
	krajcovic/rpi-mail-server:dev
