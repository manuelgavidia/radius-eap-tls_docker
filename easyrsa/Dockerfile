FROM alpine:3.6

RUN apk add --no-cache --upgrade openssl ca-certificates wget tar && \
    addgroup -g 101 radius && \
    adduser -u 100 -D -G radius radius && \
    apk add ca-certificates wget && \
    update-ca-certificates

WORKDIR /easyrsa
COPY entrypoint.sh .
RUN wget -qO- https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.5/EasyRSA-nix-3.0.5.tgz | tar xvz --strip-components=1 && \
    chmod u+x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
CMD ["help"]
