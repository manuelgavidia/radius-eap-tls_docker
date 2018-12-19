FROM alpine:3.8 as build
MAINTAINER Manuel Gavidia <manuelg@cpqd.com.br>

RUN apk update && apk upgrade

RUN apk add --update freeradius freeradius-eap openssl && \
    chgrp radius  /usr/sbin/radiusd && chmod g+rwx /usr/sbin/radiusd && \
    rm /var/cache/apk/*

COPY default /etc/raddb/sites-enabled/default
COPY eap /etc/raddb/mods-enabled/eap

# Disable modules
RUN cd /etc/raddb/mods-enabled && \
    rm attr_filter chap digest mschap  ntlm_auth pap passwd

RUN rm -rf /etc/raddb/sites-enabled/inner-tunnel /etc/raddb/mods-config/attr_filter

# EXPOSE 1812/udp 1813/udp 18120

VOLUME /etc/raddb/certs

FROM build
CMD ["radiusd", "-X"]
