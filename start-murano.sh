#!/bin/sh
# start murano container
#
set -u

KEYSTONE_HOST=10.246.151.96
OS_RABBIT_USERID=openstack 
OS_RABBIT_PASSWORD=tpjjxkfulLUgVBfIthaj
MURANO_CONTAINER_IP=10.247.134.56
CONTAINER_NAME=murano
IMAGE_TAG=murano-helloworld

OS_USERNAME=admin 
OS_PASSWORD=admin123
OS_PROJECT_NAME=admin 
OS_DOMAIN_NAME=default 

LOCAL_MURANO_PORT=8082
LOCAL_HORIZON_PORT=8000
LOCAL_RABBIT_PORT=5672

LOG_DIR=/tmp/murano/logs

docker rm -f $CONTAINER_NAME
docker run -d -v $LOG_DIR:/logs \
    -p ${LOCAL_MURANO_PORT}:8082 -p ${LOCAL_HORIZON_PORT}:8000 -p ${LOCAL_RABBIT_PORT}:5672 \
    -p 15672:15672 -p 55672:55672 \
    -h `hostname` \
    -e OS_KEYSTONE_HOST=$KEYSTONE_HOST \
    -e OS_USERNAME_TEMP=$OS_USERNAME \
    -e OS_PASSWORD_TEMP=$OS_PASSWORD \
    -e OS_PROJECT_NAME_TEMP=$OS_PROJECT_NAME \
    -e OS_DOMAIN_NAME_TEMP=$OS_DOMAIN_NAME \
    -e OS_RABBIT_USERID=$OS_RABBIT_USERID \
    -e OS_RABBIT_PASSWORD=$OS_RABBIT_PASSWORD \
    -e OS_MURANO_API_PORT=$LOCAL_MURANO_PORT \
    -e MURANO_CONTAINER_IP=$MURANO_CONTAINER_IP \
    --name $CONTAINER_NAME \
    $IMAGE_TAG
docker ps | grep $CONTAINER_NAME
echo 
echo "To monitor the progress: tail -f $LOG_DIR/murano-init.log"
echo "More logs at $LOG_DIR if there are any issues"
echo "Connect to http://${MURANO_CONTAINER_IP}:${LOCAL_HORIZON_PORT}"
