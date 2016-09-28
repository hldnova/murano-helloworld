#! /usr/bin/env bash

set -u 

# trap stop command from docker
function sigTermTrapHandler()
{
    echo "==> At: `date`: Exiting container"
    exit 0
}

trap sigTermTrapHandler SIGTERM

if [ ! -d /logs ]; then
    echo "Error - /logs directory not present. Specify -v /log:<your_log_directory> on docker run"
    exit 2
fi

export OS_PROTOCOL=${OS_PROTOCOL:-https}
export OS_RABBIT_PORT=${OS_RABBIT_PORT:-5672}
export OS_KEYSTONE_PORT=${OS_KEYSTONE_PORT:-35357}
export OS_MURANO_API_PORT=${OS_MURANO_API_PORT:-8082}
export OS_HORIZON_PORT=${OS_HORIZON_PORT:-8000}
export OS_AUTH_URL=${OS_PROTOCOL}://${OS_KEYSTONE_HOST}:${OS_KEYSTONE_PORT}/v3
export OS_REGION=${OS_REGION:-regionOne}
export MURANO_API_URL=http://${MURANO_CONTAINER_IP}:${OS_MURANO_API_PORT}

{
  echo "[default]" 
  echo "verbose = true" 
  echo ""
  echo "[oslo_messaging_rabbit]"
  echo "rabbit_port = ${OS_RABBIT_PORT}"
  echo "rabbit_hosts = ${OS_KEYSTONE_HOST}:${OS_RABBIT_PORT}"
  echo "rabbit_userid = ${OS_RABBIT_USERID}"
  echo "rabbit_password = ${OS_RABBIT_PASSWORD}"
  echo "rabbit_ha_queues = true"
  echo ""
  echo "[database]"
  echo "connection = mysql://murano:MURANODB_PASS@localhost/murano"
  echo ""
  echo "[keystone]"
  echo "insecure = true"
  echo ""
  echo "[keystone_authtoken]"
  echo "auth_uri = ${OS_AUTH_URL}"
  echo "identity_uri=${OS_PROTOCOL}://${OS_KEYSTONE_HOST}:${OS_KEYSTONE_PORT}"
  echo "admin_user = ${OS_USERNAME_TEMP}"
  echo "admin_password = ${OS_PASSWORD_TEMP}"
  echo "admin_tenant_name = ${OS_PROJECT_NAME_TEMP}"
  echo "insecure = true"
  echo ""
  echo "[murano]"
  echo "url = http://${MURANO_CONTAINER_IP}:${OS_MURANO_API_PORT}"
  echo "insecure = true"
  echo ""
  echo "[rabbitmq]"
  echo "host = ${MURANO_CONTAINER_IP}"
  echo "port = ${OS_RABBIT_PORT}"
  echo "login = guest"
  echo "password = guest" 
  echo "virtual_host = /"
  echo ""
  echo "[ssl]"
  echo "#ca_file = /etc/ssl/certs/keystone.pem"
  echo ""
  echo "[heat]"
  echo "insecure = true"
  echo ""
  echo "[neutron]"
  echo "insecure = true"
  echo ""
  echo "[engine]"
  echo "#disable_murano_agent = true"
  echo "agent_timeout = 1200"

} > /etc/murano/murano.conf

# update horizon local_settings.py
sed -i -e 's|OPENSTACK_HOST =.*|OPENSTACK_HOST = "'$OS_KEYSTONE_HOST'"|' /root/murano/horizon/openstack_dashboard/local/local_settings.py
sed -i -e 's|OPENSTACK_KEYSTONE_URL =.*|OPENSTACK_KEYSTONE_URL = "'$OS_AUTH_URL'"|' /root/murano/horizon/openstack_dashboard/local/local_settings.py
sed -i -e 's|MURANO_API_URL =.*|MURANO_API_URL = "'$MURANO_API_URL'"|' /root/murano/horizon/openstack_dashboard/local/local_settings.py

export OS_ARGS="--insecure \
        --os-auth-url ${OS_AUTH_URL} \
        --os-username ${OS_USERNAME_TEMP} \
        --os-password ${OS_PASSWORD_TEMP} \
        --os-tenant-name ${OS_PROJECT_NAME_TEMP} \
        --os-user-domain-name ${OS_DOMAIN_NAME_TEMP} \
        --os-project-domain-name ${OS_DOMAIN_NAME_TEMP}"


echo "[rabbitmq_management]." > /etc/rabbitmq/enabled_plugins

bash /root/murano/murano-init.sh > /logs/murano-init.log 2>&1 &

tail -f /dev/null