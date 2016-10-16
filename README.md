# Murano Helloworld
## Introduction
Hello world for OpenStack Murano. For those who just started to get Murano set up for prototype or testing, it is common to run into dependencies issue of various python packages managed via native package management system and pip. The goal of this exercise is to set up Murano quickly in a docker container so that developers can focus on exploring Murano features instead of spending valable time on setting up dev environment.

This was based on the steps from http://docs.openstack.org/developer/murano/install/manual.html and http://egonzalez.org/murano-in-rdo-openstack-manual-installation/

## Prerequisites
1. Install docker (e.g., on Ubuntu: https://docs.docker.com/engine/installation/linux/ubuntulinux/)
2. In existing OpenStack, create a network/subnet connected to external network and configure DNS servers by editing the subnet so that the VMs can pull packages from internet during Murano deployment.


# Murano Helloworld
## Introduction
Hello world for OpenStack Murano. For those who just started to get Murano set up for prototype or testing, it is common to run into dependencies issue of various python packages managed via native package management system and pip. The goal of this exercise is to set up Murano quickly in a docker container so that developers can focus on exploring Murano features instead of spending valable time on setting up dev environment.

This was based on the steps from http://docs.openstack.org/developer/murano/install/manual.html and http://egonzalez.org/murano-in-rdo-openstack-manual-installation/

## Prerequisites
1. Install docker (e.g., on Ubuntu: https://docs.docker.com/engine/installation/linux/ubuntulinux/)
2. In existing OpenStack, create a network/subnet connected to external network and configure DNS servers by editing the subnet so that the VMs can pull packages from internet during Murano deployment.

# Murano Helloworld
## Introduction
Hello world for OpenStack Murano. For those who just started to get Murano set up for prototype or testing, it is common to run into dependencies issue of various python packages managed via native package management system and pip. The goal of this exercise is to set up Murano quickly in a docker container so that developers can focus on exploring Murano features instead of spending valable time on setting up dev environment.

This was based on the steps from http://docs.openstack.org/developer/murano/install/manual.html and http://egonzalez.org/murano-in-rdo-openstack-manual-installation/

## Prerequisites
1. Install docker (e.g., on Ubuntu: https://docs.docker.com/engine/installation/linux/ubuntulinux/)
2. In existing OpenStack, create a network/subnet connected to external network and configure DNS servers by editing the subnet so that the VMs can pull packages from internet during Murano deployment.


ample commands:
~/murano# murano package-list
~/murano# murano environment-list
```

## Troubleshooting
By default, the script places logs files at /tmp/murano/logs on the docker host.
* murano-dashboard.log
* murano-init.log
* mysqld.log
* murano-api.log
* murano-engine.log
* murano-rabbitmq.log

Useful information on the VMs deployed by Murano.
* /var/log/murano-agent.log
* /etc/murano/agent.conf
* /etc/resolve.conf. Make sure your DNS servers show up there.

Common issues:
* OpenStack username/password are wrong. Check murano-init.log.
* OpenStack rabbitmq username/password are wrong. This will cause deployment to timeout eventually. Check murano-engine.log.
* DNS servers not configured for the subnet. This will cause the VM not being able to pull packages from internet.
* Time skew between your docker host and OpenStack. This may show up as SSL error or 403 Proxy unacknowledged in some log files.
