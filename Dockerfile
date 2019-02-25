FROM alpine:3.8 as build
MAINTAINER Manuel Gavidia <manuelg@cpqd.com.br>

RUN echo '@edge http://dl-cdn.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories

RUN echo '@edgecommunity http://dl-cdn.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories

RUN apk add --update --no-cache freeradius freeradius-eap openssl@edge && \
    chgrp radius  /usr/sbin/radiusd && chmod g+rwx /usr/sbin/radiusd

COPY default /etc/raddb/sites-enabled/default
COPY eap /etc/raddb/mods-enabled/eap

# Disable modules
RUN cd /etc/raddb/mods-enabled && \
    rm attr_filter chap digest mschap  ntlm_auth pap passwd

RUN rm -rf /etc/raddb/sites-enabled/inner-tunnel /etc/raddb/mods-config/attr_filter

# EXPOSE 1812/udp 1813/udp 18120

RUN sed -i '/allow_vulnerable_openssl = no/ c allow_vulnerable_openssl = yes' /etc/raddb/radiusd.conf

COPY clients.conf /etc/raddb/clients.conf

COPY openssl.cnf /etc/raddb/certs

COPY gen-pki.sh .

RUN ./gen-pki.sh /etc/raddb/certs

FROM build
CMD ["radiusd", "-X"]
