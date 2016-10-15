#!/bin/sh
# start murano container
#
set -u

# keystone host of your OpenStack
KEYSTONE_HOST=10.247.134.60
# rabbitmq credentials of your OpenStack
OS_RABBIT_USERID=guest
OS_RABBIT_PASSWORD=guest
# IP address of the host on which murano container will run on
MURANO_CONTAINER_IP=10.247.134.56

OS_PROTOCOL=http
OS_USERNAME=admin 
OS_PASSWORD=password
OS_PROJECT_NAME=admin 
OS_REGION=RegionOne

LOCAL_MURANO_PORT=8082
LOCAL_HORIZON_PORT=8000
LOCAL_RABBIT_PORT=5672
OS_KEYSTONE_PUBLIC_PORT=5000
OS_KEYSTONE_ADMIN_PORT=35357

CONTAINER_NAME=murano
IMAGE_TAG=murano-helloworld
LOG_DIR=/tmp/murano/logs

docker rm -f $CONTAINER_NAME
docker run -d -v $LOG_DIR:/logs \
    -p ${LOCAL_MURANO_PORT}:8082 -p ${LOCAL_HORIZON_PORT}:8000 -p ${LOCAL_RABBIT_PORT}:5672 \
    -h `hostname` \
    -e OS_PROTOCOL=$OS_PROTOCOL \
    -e OS_KEYSTONE_HOST=$KEYSTONE_HOST \
    -e OS_KEYSTONE_PUBLIC_PORT=$OS_KEYSTONE_PUBLIC_PORT \
    -e OS_KEYSTONE_ADMIN_PORT=$OS_KEYSTONE_ADMIN_PORT \
    -e OS_USERNAME_TEMP=$OS_USERNAME \
    -e OS_PASSWORD_TEMP=$OS_PASSWORD \
    -e OS_PROJECT_NAME_TEMP=$OS_PROJECT_NAME \
    -e OS_REGION_TEMP=$OS_REGION \
    -e OS_RABBIT_USERID=$OS_RABBIT_USERID \
    -e OS_RABBIT_PASSWORD=$OS_RABBIT_PASSWORD \
    -e OS_MURANO_API_PORT=$LOCAL_MURANO_PORT \
    -e MURANO_CONTAINER_IP=$MURANO_CONTAINER_IP \
    --name $CONTAINER_NAME \
    $IMAGE_TAG
docker ps | grep $CONTAINER_NAME
echo 
echo "To monitor the progress: tail -f $LOG_DIR/murano-init.log"
echo "More logs at $LOG_DIR" 
echo "Murano dashboard: http://${MURANO_CONTAINER_IP}:${LOCAL_HORIZON_PORT}"
