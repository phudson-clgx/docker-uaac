FROM ubuntu:16.04

ENV CF_CLI_VERSION "6.40.0"
ENV CF_AUTOPILOT_VERSION="0.0.8"

# Install base packages
RUN apt-get update && apt-get -y install \
        curl \
        dnsutils \
        git \
        jq \
        unzip \
        vim \
        redis-tools \
        libreadline-dev \
        build-essential \
        autoconf \
        automake \
        libtool \
        make \
        gcc \
        g++ \
        libpq-dev \
        tzdata \
        software-properties-common \
        wget \
        openssl
RUN apt-get update && \
          apt-get install -y --no-install-recommends locales && \
          locale-gen en_US.UTF-8 && \
          apt-get dist-upgrade -y && \
          apt-get --purge remove openjdk* && \
          echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
          #echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" > /etc/apt/sources.list.d/webupd8team-java-trusty.list && \
          #apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886 && \
          add-apt-repository ppa:webupd8team/java && \
          apt-get update && \
          apt-get install -y --no-install-recommends oracle-java8-installer oracle-java8-set-default && \
          apt-get clean all
RUN git clone https://github.com/rbenv/rbenv.git /usr/local/rbenv \
    &&  git clone https://github.com/rbenv/ruby-build.git /usr/local/rbenv/plugins/ruby-build \
    &&  git clone https://github.com/jf/rbenv-gemset.git /usr/local/rbenv/plugins/rbenv-gemset \
    &&  /usr/local/rbenv/plugins/ruby-build/install.sh
ENV PATH /usr/local/rbenv/bin:$PATH
ENV RBENV_ROOT /usr/local/rbenv

RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /etc/profile.d/rbenv.sh \
    &&  echo 'export PATH=/usr/local/rbenv/bin:$PATH' >> /etc/profile.d/rbenv.sh \
    &&  echo 'eval "$(rbenv init -)"' >> /etc/profile.d/rbenv.sh

RUN echo 'export RBENV_ROOT=/usr/local/rbenv' >> /root/.bashrc \
    &&  echo 'export PATH=/usr/local/rbenv/bin:$PATH' >> /root/.bashrc \
    &&  echo 'eval "$(rbenv init -)"' >> /root/.bashrc

ENV CONFIGURE_OPTS --disable-install-doc
ENV PATH /usr/local/rbenv/bin:/usr/local/rbenv/shims:$PATH

ENV RBENV_VERSION 2.5.1

RUN eval "$(rbenv init -)"; rbenv install $RBENV_VERSION \
    &&  eval "$(rbenv init -)"; rbenv global $RBENV_VERSION \
    &&  eval "$(rbenv init -)"; gem update --system \
    &&  eval "$(rbenv init -)"; gem install bundler -f \
    &&  rm -rf /tmp/*
RUN set -e; \
    curl -L "https://cli.run.pivotal.io/stable?release=linux64-binary&version=${CF_CLI_VERSION}" | tar -zx -C /usr/local/bin; \
    cf install-plugin https://github.com/contraband/autopilot/releases/download/${CF_AUTOPILOT_VERSION}/autopilot-linux -f

RUN gem install cf-uaac
RUN mkdir /root/.ssh
RUN chmod -R 600 /root/.ssh
RUN mkdir /root/.pcf/
COPY id_rsa /root/.ssh
COPY config-server/config-server-cipher.sh /root
COPY config-server/config-server-prereq.sh /root
COPY uaa/uaa-login.sh /root
COPY uaa/uaa.config /root/.pcf/
RUN chmod -R 600 /root/.ssh && \
    chmod +x /root/config-server-cipher.sh && \
    chmod +x /root/config-server-prereq.sh && \
    chmod +x /root/uaa-login.sh
COPY config-server/config-server-cipher.config /root/.pcf/config-server-cipher.config
COPY config-server/local_policy.jar /usr/lib/jvm/java-8-oracle/jre/lib/security/local_policy.jar
COPY config-server/US_export_policy.jar /usr/lib/jvm/java-8-oracle/jre/lib/security/US_export_policy.jar
#RUN bash /root/config-server-cipher.sh encrypt preprod test
RUN echo "Host github.com\n\tStrictHostKeyChecking no\n" >> /root/.ssh/config
RUN bash /root/config-server-prereq.sh
#CMD tail -f /dev/null
COPY entrypoint.sh /root/entrypoint.sh
COPY uaa/uaa-add.sh /root
RUN chmod +x /root/uaa-add.sh
COPY uaa/uaa-update.sh /root
RUN chmod +x /root/uaa-update.sh
COPY uaa/uaa-get.sh /root
RUN chmod +x /root/uaa-get.sh
ENTRYPOINT ["bash", "/root/entrypoint.sh"]
