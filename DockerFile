FROM ubuntu:focal
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update; \
    \
    apt install -y --no-install-recommends \
      libev-dev \
      python3-pip \
      python3-dev \
      libczmq-dev
