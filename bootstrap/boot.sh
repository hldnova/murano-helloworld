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
    echo "Error - /logs directory not present. Specify -v /logs:<your_log_directory>"
    exit 2
fi

export OS_PROTOCOL=${OS_PROTOCOL:-http}
export OS_KEYSTONE_PUBLIC_PORT=${OS_KEYSTONE_PUBLIC_PORT:-5000}
export OS_KEYSTONE_ADMIN_PORT=${OS_KEYSTONE_ADMIN_PORT:-35357}
export OS_AUTH_URL=${OS_PROTOCOL}://${OS_KEYSTONE_HOST}:${OS_KEYSTONE_PUBLIC_PORT}/v2.0
export OS_IDENTITY_URL=${OS_PROTOCOL}://${OS_KEYSTONE_HOST}:${OS_KEYSTONE_ADMIN_PORT}
export OS_REGION=${OS_REGION_TEMP:-RegionOne}
export MURANO_HORIZON_PORT=${MURANO_HORIZON_PORT:-8000}
export MURANO_API_PORT=${MURANO_MURANO_API_PORT:-8082}
export MURANO_API_URL=http://${MURANO_CONTAINER_IP}:${MURANO_API_PORT}
export MURANO_RABBIT_PORT=${MURANO_RABBIT_PORT:-5672}
export OS_RABBIT_HOST=${OS_RABBIT_HOST}
export OS_RABBIT_PORT=${OS_RABBIT_PORT:-5672}
export OS_RABBIT_USERNAME=${OS_RABBIT_USERNAME}
export OS_RABBIT_PASSWORD=${OS_RABBIT_PASSWORD}

{
  echo "[default]" 
  echo "verbose = true" 
  echo ""
  echo "[oslo_messaging_rabbit]"
  echo "rabbit_host = ${OS_RABBIT_HOST}"
  echo "rabbit_port = ${OS_RABBIT_PORT}"
  echo "rabbit_hosts = ${OS_RABBIT_HOST}:${OS_RABBIT_PORT}"
  echo "rabbit_use_ssl = False"
  echo "rabbit_userid = ${OS_RABBIT_USERNAME}"
  echo "rabbit_password = ${OS_RABBIT_PASSWORD}"
  echo "rabbit_virtual_host = /"
  echo "rabbit_ha_queues = False"
  echo "rabbit_notification_exchange = openstack"
  echo "rabbit_notification_topic = notifications"
  echo ""
  echo "[database]"
  echo "connection = mysql://murano:MURANODB_PASS@localhost/murano"
  echo ""
  echo "[keystone]"
  echo "insecure = true"
  echo ""
  echo "[keystone_authtoken]"
  echo "auth_uri = ${OS_AUTH_URL}"
  echo "identity_uri = ${OS_IDENTITY_URL}"
  echo "admin_user = ${OS_USERNAME_TEMP}"
  echo "admin_password = ${OS_PASSWORD_TEMP}"
  echo "admin_tenant_name = ${OS_PROJECT_NAME_TEMP}"
  echo "insecure = true"
  echo ""
  echo "[murano]"
  echo "url = ${MURANO_API_URL}"
  echo "insecure = true"
  echo ""
  echo "[rabbitmq]"
  echo "host = ${MURANO_CONTAINER_IP}"
  echo "port = ${MURANO_RABBIT_PORT}"
  echo "login = ${OS_RABBIT_USERNAME}"
  echo "password = ${OS_RABBIT_PASSWORD}" 
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
sed -i -e  "s|#ALLOWED_HOSTS = .*|ALLOWED_HOSTS = ['*']|" /root/murano/horizon/openstack_dashboard/local/local_settings.py
echo "MURANO_API_URL = '$MURANO_API_URL'" >> /root/murano/horizon/openstack_dashboard/local/local_settings.py

{
  echo ""
  echo "DATABASES = {"
  echo "  'default': {"
  echo "  'ENGINE': 'django.db.backends.sqlite3',"
  echo "  'NAME': 'murano-dashboard.sqlite',"
  echo "  }"
  echo "}"

  echo "SESSION_ENGINE = 'django.contrib.sessions.backends.db'"
} >> /root/murano/horizon/openstack_dashboard/local/local_settings.py

export OS_ARGS="--insecure \
        --os-auth-url ${OS_AUTH_URL} \
        --os-username ${OS_USERNAME_TEMP} \
        --os-password ${OS_PASSWORD_TEMP} \
        --os-tenant-name ${OS_PROJECT_NAME_TEMP}" 

echo "[rabbitmq_management]." > /etc/rabbitmq/enabled_plugins

bash /root/murano/murano-init.sh > /logs/murano-init.log 2>&1 &

# generate openstack rc file
{
  echo "unset \${!OS_*}"
  echo "export OS_USERNAME=${OS_USERNAME_TEMP}"
  echo "export OS_PASSWORD=${OS_PASSWORD_TEMP}"
  echo "export OS_AUTH_URL=${OS_AUTH_URL}"
  echo "export OS_TENANT_NAME=${OS_PROJECT_NAME_TEMP}"
} > /root/murano/keystonerc

tail -f /dev/null
