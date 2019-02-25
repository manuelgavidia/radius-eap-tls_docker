#!/bin/bash

# Build containers
docker build -t manuelgavidia/freeradius_eap_tls .

# Get certs
rm -rf certs
id=$(docker create --rm manuelgavidia/freeradius_eap_tls)
docker cp ${id}:/etc/raddb/certs/ certs
docker rm ${id}

# Creates eapol configuration test file
sed -s "s@ROOT@${PWD}@g" eapool_template.conf > test.conf
