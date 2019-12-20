#!/bin/bash

CONTAINER_NAME=hass
IMAGE_NAME=hass-img

docker rm -f $CONTAINER_NAME
docker rmi --force $IMAGE_NAME
docker build -t $IMAGE_NAME -f ./docker/Dockerfile . &&
docker run -td -p 8123:8123 --name $CONTAINER_NAME $IMAGE_NAME