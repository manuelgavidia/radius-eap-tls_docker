#!/bin/bash

NAME=freeradius/test_eap

# Build containers
docker build -t ${NAME} .
docker build easyrsa -t easyrsa

# Creates certs
docker run -it -v pki:/easyrsa/pki easyrsa build-client-full client

# Get certs
rm -rf certs
id=$(docker create -v pki:/etc/raddb/certs:ro --rm ${NAME})
docker cp ${id}:/etc/raddb/certs/ certs
docker rm ${id}
sed -s "s@ROOT@${PWD}@g" eapool_template.conf > test.conf

docker-compose up freeradius
