FROM alpine:edge as build
MAINTAINER Manuel Gavidia <manuelg@cpqd.com.br>

RUN apk update && apk upgrade

RUN apk add --no-cache --update freeradius freeradius-eap openssl && \
    chgrp radius  /usr/sbin/radiusd && chmod g+rwx /usr/sbin/radiusd

COPY default /etc/raddb/sites-enabled/default
COPY eap /etc/raddb/mods-enabled/eap

# Disable modules
RUN cd /etc/raddb/mods-enabled && \
    rm attr_filter chap digest mschap  ntlm_auth pap passwd

RUN rm -rf /etc/raddb/sites-enabled/inner-tunnel /etc/raddb/mods-config/attr_filter

# EXPOSE 1812/udp 1813/udp 18120

RUN sed -i '/allow_vulnerable_openssl = no/ c allow_vulnerable_openssl = yes' /etc/raddb/radiusd.conf

VOLUME /etc/raddb/certs

FROM build
CMD ["radiusd", "-X"]
