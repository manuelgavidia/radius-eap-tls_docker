#!/bin/bash

# Build containers
docker build -t manuelgavidia/radius-tls-eap .

# Get certs
rm -rf certs
id=$(docker create --rm manuelgavidia/radius-tls-eap)
docker cp ${id}:/etc/raddb/certs/ certs
docker rm ${id}

# Creates eapol configuration test file
sed -s "s@ROOT@${PWD}@g" eapool_template.conf > test.conf
