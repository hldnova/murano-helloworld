FROM ubuntu:trusty
MAINTAINER lida.he@emc.com

RUN apt-get update

RUN apt-get -y install \
    python-setuptools \
    git \
    zip \
    curl \
    wget 

RUN apt-get -y install \
    python-dev \
    python-mysqldb \
    libmysqlclient-dev \
    libpq-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    mysql-server \
    rabbitmq-server


RUN easy_install pip && \
    pip install --upgrade pip && \
    pip install requests[security]

RUN mkdir -p /var/log/mysql && \
    mysql_install_db --user=mysql --ldata=/var/lib/mysql/

ADD bootstrap/requirements.txt /root/

# install murano
RUN mkdir ~/murano && \
    cd ~/murano && \
    git config --global http.sslVerify false && \
    git clone -b stable/liberty https://github.com/openstack/murano && \
    cd murano && \
    pip install -r ../../requirements.txt && \
    python setup.py install && \
    cd ~/murano/murano/meta/io.murano && \
    zip -r ../../io.murano.zip * && \
    mkdir -p /etc/murano && \
    cp ~/murano/murano/etc/murano/* /etc/murano && \
    rm -rf ~/murano/murano/.git 

RUN cd ~/murano && \
    git clone -b stable/liberty https://github.com/openstack/murano-dashboard && \
    git clone -b stable/liberty https://github.com/openstack/horizon  && \
    cd horizon && \
    pip install -r requirements.txt && \
    pip install -e ../murano-dashboard && \
    cp ../murano-dashboard/muranodashboard/local/_50_murano.py openstack_dashboard/local/enabled/ && \
    rm -rf ~/murano/horizon/.git && \
    rm -rf ~/murano/murano-dashboard/.git && \
    rm -rf ~/murano/app-catalog-ui/.git

ENV TERM=xterm

ADD bootstrap/local_settings.py /root/murano/horizon/openstack_dashboard/local/

ADD bootstrap/boot.sh /root/murano/
ADD bootstrap/murano-init.sh /root/murano/
ADD bootstrap/rabbitmq.config /etc/rabbitmq/

EXPOSE 8082 8000 5672 15672 55672

WORKDIR "/root/murano"
ENTRYPOINT ["/root/murano/boot.sh"]

