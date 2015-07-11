# FROM 		progrium/busybox
# MAINTAINER 	Jeff Lindsay <progrium@gmail.com>

FROM man:5000/alpine:3.2

RUN apk update
RUN apk add ca-certificates

# glibc: https://circle-artifacts.com/gh/andyshinn/alpine-pkg-glibc/6/artifacts/0/home/ubuntu/alpine-pkg-glibc/packages/x86_64/glibc-2.21-r2.apk
COPY deps/glibc-2.21-r2.apk /tmp/glibc-2.21-r2.apk
RUN apk add --allow-untrusted /tmp/glibc-2.21-r2.apk

# consul: https://dl.bintray.com/mitchellh/consul/0.5.2_linux_amd64.zip
COPY deps/consul_0.5.2_linux_amd64.zip /tmp/consul.zip
RUN cd /bin && unzip /tmp/consul.zip && chmod +x /bin/consul

# consul UI: https://dl.bintray.com/mitchellh/consul/0.5.2_web_ui.zip
COPY deps/consul_0.5.2_web_ui.zip /tmp/consul_web_ui.zip
RUN mkdir -p /ui && cd /ui && unzip /tmp/consul_web_ui.zip && mv dist/* ./ && rm -rf dist

# docker: https://get.docker.io/builds/Linux/x86_64/docker-1.6.2
ADD deps/docker-1.6.2 /bin/docker
RUN chmod +x /bin/docker

RUN rm -rf /var/cache/apk/* && rm -rf /tmp/*

# RUN opkg-install curl bash ca-certificates

# RUN cat /etc/ssl/certs/*.crt > /etc/ssl/certs/ca-certificates.crt && \
#    sed -i -r '/^#.+/d' /etc/ssl/certs/ca-certificates.crt

ADD ./config /config/
ONBUILD ADD ./config /config/

ADD ./start /bin/start
ADD ./check-http /bin/check-http
ADD ./check-cmd /bin/check-cmd

EXPOSE 8300 8301 8301/udp 8302 8302/udp 8400 8500 53 53/udp
VOLUME ["/data"]

ENV SHELL /bin/bash

ENTRYPOINT ["/bin/start"]
CMD []
