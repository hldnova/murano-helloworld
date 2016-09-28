#!/bin/sh
# start murano container
#
set -u

#pod4
#NEUTRINO_VIP=10.246.152.160
#OS_RABBIT_PASSWORD=NwaloBiHtOoudwjfhYIO

#pod3
NEUTRINO_VIP=10.246.151.160
OS_RABBIT_PASSWORD=hsPeOezUYytEBhtOqbVu

#pod2
NEUTRINO_VIP=10.246.151.96
OS_RABBIT_PASSWORD=tpjjxkfulLUgVBfIthaj

CONTAINER_IP=10.247.134.56
LOG_DIR=/tmp/murano/logs
OS_USERNAME=admin 
OS_PASSWORD=admin123 
OS_TENANT_NAME=admin 
OS_DOMAIN_NAME=default 
OS_RABBIT_USERID=openstack 

#IMAGE_TAG=emccorp/nmurano
IMAGE_TAG=murano-helloworld-mitaka
MURANO_PORT=8082
HORIZON_PORT=8000
RABBIT_PORT=5672
CONTAINER_NAME=murano

docker rm -f $CONTAINER_NAME
docker run -d -v $LOG_DIR:/logs \
    -p ${MURANO_PORT}:8082 -p ${HORIZON_PORT}:8000 -p ${RABBIT_PORT}:5672 -p 15672:15672 -p 55672:55672 \
    --name $CONTAINER_NAME \
    -h `hostname` \
    -e VIP=$NEUTRINO_VIP \
    -e CONTAINER_IP=$CONTAINER_IP \
    -e OS_USERNAME=$OS_USERNAME \
    -e OS_PASSWORD=$OS_PASSWORD \
    -e OS_TENANT_NAME=$OS_TENANT_NAME \
    -e OS_DOMAIN_NAME=$OS_DOMAIN_NAME \
    -e OS_RABBIT_USERID=$OS_RABBIT_USERID \
    -e OS_RABBIT_PASSWORD=$OS_RABBIT_PASSWORD \
    $IMAGE_TAG
docker ps | grep $CONTAINER_NAME
echo 
echo "To monitor the progress: tail -f $LOG_DIR/murano-init.log"
echo "More logs at $LOG_DIR if there are any issues"
echo "Connect to http://${CONTAINER_IP}:${HORIZON_PORT}"

