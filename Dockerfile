FROM openjdk:8-jdk
MAINTAINER Felix Russell <frussell@uw.edu>

ARG VERSION=3.29
ARG user=root
ARG group=root
ARG uid=1000
ARG gid=1000

ENV HOME /home/${user}
# RUN groupadd -g ${gid} ${group}
# RUN useradd -c "Jenkins user" -d $HOME -u ${uid} -g ${gid} -m ${user}
LABEL Description="This is a base image, which provides the Jenkins agent executable (slave.jar)" Vendor="Jenkins project" Version="${VERSION}"

ARG AGENT_WORKDIR=/home/${user}/agent

RUN echo 'deb http://deb.debian.org/debian stretch-backports main' > /etc/apt/sources.list.d/stretch-backports.list
RUN apt-get update && apt-get install -t stretch-backports git-lfs
RUN curl --create-dirs -fsSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/${user}/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/${user}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}

RUN git clone https://github.com/jenkinsci/docker-jnlp-slave.git
COPY docker-jnlp-slave/jenkins-slave /usr/local/bin/jenkins-slave

RUN wget https://download.docker.com/linux/static/stable/x86_64/docker-18.06.3-ce.tgz \
  && tar xvzf docker-18.06.3-ce.tgz \
  && ln -s docker/docker /usr/local/bin/docker

ENTRYPOINT ["jenkins-slave"]