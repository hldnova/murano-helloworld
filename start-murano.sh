#!/bin/sh
# start murano container
#
set -u

OS_KEYSTONE_HOST=192.168.100.60
OS_USERNAME=admin 
OS_PASSWORD=password
OS_PROJECT_NAME=admin 

# IP address of the host to run Murano container
MURANO_CONTAINER_IP=192.168.100.70

# --- In general you don't need to edit anything below ---

# To use existing OpenStack rabbitmq for communication between 
# Murano services in the container, modified the 4 parameters below.
# By default, single rabbitmq is started in the container for
# both Murano and VMs.
OS_RABBIT_HOST=${MURANO_CONTAINER_IP}
OS_RABBIT_PORT=5672
OS_RABBIT_USERNAME=guest
OS_RABBIT_PASSWORD=guest

OS_KEYSTONE_PUBLIC_PORT=5000
OS_KEYSTONE_ADMIN_PORT=35357
OS_REGION=RegionOne
OS_PROTOCOL=http

MURANO_API_PORT=8082
MURANO_HORIZON_PORT=8000
MURANO_RABBIT_PORT=5672

# If you build docker image locally, change this to your image name. Otherwise
# docker will pull the image from docker hub.
IMAGE_TAG=lidaheemc/murano-helloworld
CONTAINER_NAME=murano
LOG_DIR=/tmp/murano/logs

docker rm -f $CONTAINER_NAME
docker run -d -v $LOG_DIR:/logs \
    -p ${MURANO_API_PORT}:8082 -p ${MURANO_HORIZON_PORT}:8000 -p ${MURANO_RABBIT_PORT}:5672 \
    -h `hostname` \
    -e OS_KEYSTONE_HOST=$OS_KEYSTONE_HOST \
    -e OS_KEYSTONE_PUBLIC_PORT=$OS_KEYSTONE_PUBLIC_PORT \
    -e OS_KEYSTONE_ADMIN_PORT=$OS_KEYSTONE_ADMIN_PORT \
    -e OS_USERNAME_TEMP=$OS_USERNAME \
    -e OS_PASSWORD_TEMP=$OS_PASSWORD \
    -e OS_PROJECT_NAME_TEMP=$OS_PROJECT_NAME \
    -e OS_PROTOCOL=$OS_PROTOCOL \
    -e OS_REGION_TEMP=$OS_REGION \
    -e OS_RABBIT_HOST=${OS_RABBIT_HOST} \
    -e OS_RABBIT_PORT=${OS_RABBIT_PORT} \
    -e OS_RABBIT_USERNAME=${OS_RABBIT_USERNAME} \
    -e OS_RABBIT_PASSWORD=${OS_RABBIT_PASSWORD} \
    -e MURANO_API_PORT=$MURANO_API_PORT \
    -e MURANO_RABBIT_PORT=$MURANO_RABBIT_PORT \
    -e MURANO_CONTAINER_IP=$MURANO_CONTAINER_IP \
    --name $CONTAINER_NAME \
    $IMAGE_TAG
docker ps | grep $CONTAINER_NAME
echo 
echo "To monitor the progress: tail -f $LOG_DIR/murano-init.log"
echo "More logs at $LOG_DIR" 
echo "Murano dashboard: http://${MURANO_CONTAINER_IP}:${MURANO_HORIZON_PORT}"
