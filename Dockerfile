FROM centos:latest
MAINTAINER "Nick Griffin" <nicholas.griffin@accenture.com>

# Java Env Variables
ENV JAVA_VERSION=1.8.0_152
ENV JAVA_TARBALL=jdk-8u152-linux-x64.tar.gz
ENV JAVA_HOME=/opt/java/jdk${JAVA_VERSION}

# Swarm Env Variables (defaults)
ENV SWARM_MASTER=http://jenkins:8080/jenkins/
ENV SWARM_USER=jenkins
ENV SWARM_PASSWORD=jenkins

# Slave Env Variables
ENV SLAVE_NAME="Swarm_Slave"
ENV SLAVE_LABELS="docker aws ldap"
ENV SLAVE_MODE="exclusive"
ENV SLAVE_EXECUTORS=1
ENV SLAVE_DESCRIPTION="Core Jenkins Slave"

# Pre-requisites
RUN yum -y install epel-release
RUN yum install -y which \
    git \
    wget \
    tar \
    zip \
    unzip \
    openldap-clients \
    openssl \
    python-pip \
    yum-utils \
    device-mapper-persistent-data \
    lvm2 \
    java-1.8.0-openjdk-devel \
    libxslt && \
    yum clean all 

RUN pip install awscli==1.10.19
  
RUN yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

RUN yum -y install docker-ce && yum clean all

# Docker versions Env Variables
#ENV DOCKER_ENGINE_VERSION=1.10.3-1.el7.centos
#ENV DOCKER_COMPOSE_VERSION=1.6.0
#ENV DOCKER_MACHINE_VERSION=v0.6.0

#RUN curl -fsSL https://get.docker.com/ | sed "s/docker-engine/docker-engine-${DOCKER_ENGINE_VERSION}/" | sh

#RUN curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
    #chmod +x /usr/local/bin/docker-compose
#RUN curl -L https://github.com/docker/machine/releases/download/${DOCKER_MACHINE_VERSION}/docker-machine-`uname -s`-`uname -m` >/usr/local/bin/docker-machine && \
    #chmod +x /usr/local/bin/docker-machine

RUN wget --no-cookies --directory-prefix=/tmp --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/8u152-b16/aa0333dd3019491ca4f6ddbe78cdb6d0/${JAVA_TARBALL}"
RUN mkdir -p /opt/java
RUN tar -xzf /tmp/${JAVA_TARBALL} -C /opt/java/ 
RUN alternatives --install /usr/bin/java java /opt/java/jdk${JAVA_VERSION}/bin/java 100
RUN rm -rf /tmp/* && rm -rf /var/log/*

# Make Jenkins a slave by installing swarm-client
RUN curl -s -o /bin/swarm-client.jar -k http://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/3.6/swarm-client-3.6.jar

# Start Swarm-Client
CMD java -jar /bin/swarm-client.jar -executors ${SLAVE_EXECUTORS} -description "${SLAVE_DESCRIPTION}" -master ${SWARM_MASTER} -username ${SWARM_USER} -password ${SWARM_PASSWORD} -name "${SLAVE_NAME}" -labels "${SLAVE_LABELS}" -mode ${SLAVE_MODE}
