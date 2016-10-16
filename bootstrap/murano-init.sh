#! /usr/bin/env bash

set -u 

# start rabbitmq server for murano agent
set -x
/usr/sbin/rabbitmq-server > /logs/murano-rabbitmq.log 2>&1 &

# start mysql server
/usr/bin/mysqld_safe --log-error=/logs/mysqld.log &
set +x
sleep 10

if [ ! -e ~/murano/murano_first_boot ] 
then
    # create murano db and user
    set -x
    echo "CREATE DATABASE murano;" | mysql
    echo "GRANT ALL PRIVILEGES ON murano.* TO 'murano'@'localhost' IDENTIFIED BY 'MURANODB_PASS';" | mysql
    echo "GRANT ALL PRIVILEGES ON murano.* TO 'murano'@'%' IDENTIFIED BY 'MURANODB_PASS';" | mysql
    set +x
fi

set -x
murano-db-manage --config-file /etc/murano/murano.conf upgrade
set +x

# start murano api service
set -x
murano-api --config-file /etc/murano/murano.conf > /logs/murano-api.log 2>&1 &
set +x
sleep 5

if [ ! -e ~/murano/murano_first_boot ]
then

    svc_type="application-catalog"
    svc_name="murano-"${MURANO_CONTAINER_IP}

    cd ~/murano/murano

    # Get murano catalog service id
    SERVICE_IDS=`openstack $OS_ARGS  service list | grep $svc_name | grep $svc_type | awk '{print $2}'`

    for x in `echo $SERVICE_IDS`
    do
        set -x 
        openstack $OS_ARGS service delete $x
        set +x
    done

    set -x
    openstack $OS_ARGS service create --name $svc_name $svc_type
    set +x

    # create murano endpoint. delete the old one and create a new one.
    # be careful not to create too many. The token could get too big that could eventually
    # "paralyze" keystone. 
    EP_IDS=`openstack $OS_ARGS endpoint list | grep $MURANO_CONTAINER_IP | grep $svc_type | awk '{print $2}'`

    for x in `echo $EP_IDS`
    do
        set -x
        openstack $OS_ARGS endpoint delete $x
        set +x
    done

    # Get murano service catalog id
    SERVICE_ID=`openstack $OS_ARGS service list | grep $svc_name | grep $svc_type | awk '{print $2}'`

    # Create murano endpoints
    set -x
    openstack $OS_ARGS endpoint create \
       --region $OS_REGION \
       --adminurl http://${MURANO_CONTAINER_IP}:${MURANO_API_PORT} \
       --publicurl http://${MURANO_CONTAINER_IP}:${MURANO_API_PORT} \
       --internalurl http://${MURANO_CONTAINER_IP}:${MURANO_API_PORT} \
       $SERVICE_ID

    # import core library
    murano $OS_ARGS --murano-url http://${MURANO_CONTAINER_IP}:${MURANO_API_PORT} \
        package-import --is-public --exists-action u io.murano.zip
    set +x
    touch ~/murano/murano_first_boot
fi


# start murano enging
echo "Start murano engine"
cd ~/murano/murano
set -x
murano-engine --config-file /etc/murano/murano.conf > /logs/murano-engine.log 2>&1 &
set +x

# Start horizon
echo "Start horizon"
cd ~/murano/horizon
set -x
python manage.py migrate
python manage.py runserver 0.0.0.0:${MURANO_HORIZON_PORT} > /logs/murano-dashboard.log 2>&1 &
set +x
ln -s /logs ~/murano/logs
sleep 5
echo "Murano started. Connect to http://${MURANO_CONTAINER_IP}:${MURANO_HORIZON_PORT}"
