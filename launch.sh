#!/bin/bash

NAME=freeradius/test_eap

# Build container
docker build -t ${NAME} .

# Get certs
id=$(docker create --rm ${NAME})
docker cp ${id}:/certs-client certs
docker rm ${id}
sed -s "s@ROOT@${PWD}@g" eapool_template.conf > test.conf

docker-compose up freeradius
