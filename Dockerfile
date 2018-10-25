FROM alpine:3.8 as build
MAINTAINER Muhamed Avila <muhamed@cpqd.com.br>

RUN apk update && apk upgrade

RUN apk add --update freeradius freeradius-eap openssl make freeradius-sqlite freeradius-radclient freeradius-rest openssl-dev && \
    chgrp radius  /usr/sbin/radiusd && chmod g+rwx /usr/sbin/radiusd && \
    rm /var/cache/apk/* && \
    cd /etc/raddb/certs/ && \
    make ca.pem && \
    make ca.der && \
    make server.pem && \
    make client.pem && \
    openssl dhparam -check -text -5 512 -out dh

COPY default /etc/raddb/sites-enabled/default
COPY eap /etc/raddb/mods-enabled/eap

RUN mkdir /certs-client && mv /etc/raddb/certs/client*.* /certs-client  && \
    cp /etc/raddb/certs/ca.pem /certs-client/

# Disable modules
RUN cd /etc/raddb/mods-enabled && \
    rm attr_filter chap digest mschap  ntlm_auth pap passwd

RUN rm -rf /etc/raddb/sites-enabled/inner-tunnel /etc/raddb/mods-config/attr_filter


# EXPOSE 1812/udp 1813/udp 18120

FROM build
CMD ["radiusd", "-X"]
