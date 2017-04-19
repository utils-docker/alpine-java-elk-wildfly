FROM fabioluciano/alpine-java-base
MAINTAINER Fábio Luciano <fabioluciano@php.net>
LABEL Description="Alpine Java Wildfly"

ARG wildfly_version
ENV wildfly_version ${wildfly_version:-"10.1.0.Final"}

ARG wildfly_username
ENV wildfly_username ${wildfly_username:-"wildfly"}

ARG wildfly_password
ENV wildfly_password ${wildfly_password:-"password"}

ENV wildfly_url "http://download.jboss.org/wildfly/${wildfly_version}/wildfly-wildfly_version.tar.gz"

################

RUN apk --update --no-cache add tar curl openssh

RUN printf "${wildfly_password}\n${wildfly_password}" | adduser ${wildfly_username} \
  && printf "\n\n" | ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key \
  && printf "\n\n" | ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key \
  && printf "\n\n" | ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key \
  && printf "\n\n" | ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key \
  && echo "AllowUsers ${wildfly_username}" >> /etc/ssh/sshd_config

COPY files/supervisord.conf /etc/
COPY files/supervisor/* /etc/supervisor.d/
