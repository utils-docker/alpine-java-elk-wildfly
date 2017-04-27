FROM fabioluciano/alpine-base-java
MAINTAINER Fábio Luciano <fabioluciano@php.net>
LABEL Description="Alpine Java Wildfly"

ARG wildfly_version
ENV wildfly_version ${wildfly_version:-"10.1.0.Final"}

ARG wildfly_username
ENV wildfly_username ${wildfly_username:-"wildfly"}

ARG wildfly_password
ENV wildfly_password ${wildfly_password:-"password"}

ARG wildfly_target_dir
ENV wildfly_target_dir ${wildfly_target_dir:-"/opt/wildfly/"}

ENV wildfly_url "http://download.jboss.org/wildfly/${wildfly_version}/wildfly-${wildfly_version}.tar.gz"

ARG elastico_logstash
ENV elastico_logstash ${elastico_logstash:-"http://logstash.devops"}

################

RUN apk --update --no-cache add openssh

WORKDIR /opt

## Configure SSH
RUN printf "${wildfly_password}\n${wildfly_password}" | adduser ${wildfly_username} \
  && printf "\n\n" | ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key \
  && printf "\n\n" | ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key \
  && printf "\n\n" | ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key \
  && printf "\n\n" | ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key \
  && echo "AllowUsers ${wildfly_username}" >> /etc/ssh/sshd_config

# -Duser.timezone=America/Sao_Paulo -Duser.country=BR -Duser.language=pt

## Configure Wildfly
RUN curl -L ${wildfly_url} > wildfly.tar.gz \
  && directory=$(tar tfz wildfly.tar.gz --exclude '*/*') \
  && tar -xzf wildfly.tar.gz && rm wildfly.tar.gz \
  && mv $directory wildfly \
  && chown ${wildfly_username}:${wildfly_username} /opt/wildfly -R

COPY files/supervisor/* /etc/supervisor.d/

COPY files/beats/*.yml /tmp/
RUN cat /tmp/filebeat.yml >> /opt/monitor/filebeat/filebeat.yml
RUN cat /tmp/heartbeat.yml >> /opt/monitor/heartbeat/heartbeat.yml

EXPOSE 8080/tcp 8443/tcp 9990/tcp
