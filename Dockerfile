FROM alpine:3.9 as build

MAINTAINER Manuel Gavidia <manuelg@cpqd.com.br>

RUN apk add --update --no-cache freeradius freeradius-eap openssl && \
    chgrp radius  /usr/sbin/radiusd && chmod g+rwx /usr/sbin/radiusd

COPY default /etc/raddb/sites-enabled/default
COPY eap /etc/raddb/mods-enabled/eap

RUN sed -i '/allow_vulnerable_openssl = no/ c allow_vulnerable_openssl = yes' /etc/raddb/radiusd.conf

COPY clients.conf /etc/raddb/clients.conf

COPY openssl.cnf /etc/raddb/certs

COPY gen-pki.sh .

RUN ./gen-pki.sh /etc/raddb/certs

FROM build
CMD ["radiusd", "-X"]
