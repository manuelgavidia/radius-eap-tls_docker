#!/bin/bash

# Build containers
docker build -t manuelgavidia/radius-tls-eap .
docker build -f Dockerfile-genpki -t manuelgavidia/genpki .

# Creates certs
docker run -it -v pki:/etc/raddb/certs manuelgavidia/genpki

# Get certs
rm -rf certs
id=$(docker create -v pki:/etc/raddb/certs:ro --rm manuelgavidia/radius-tls-eap)
docker cp ${id}:/etc/raddb/certs/ certs
docker rm ${id}

# Creates eapol configuration test file
sed -s "s@ROOT@${PWD}@g" eapool_template.conf > test.conf
