FROM ubuntu:focal
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update; \
    apt-get upgrade; \
    apt install -y --no-install-recommends \
      libev-dev \
      python3-pip \
      python3-dev \
      libczmq-dev;
CMD useradd -mp "$(openssl passwd -crypt jupyter)" jupyter; \
    usermod -aG sudo jupyter; \
    usermod -s /bin/bash jupyter; \
    mkdir -p /home/jupyter/.local/bin; \
    bash
