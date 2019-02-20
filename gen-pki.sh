#!/bin/sh -e

CA_DIR=${1:-/etc/raddb/certs}
export OPENSSL_CONF=${CA_DIR}/openssl.cnf
export RANDFILE=${CA_DIR}/private/.rand

cd ${CA_DIR}

create_cert() {
  local CA_EXTRA=""
  [ "${1}" = "ca" ] && CA_EXTRA="-selfsign"

  openssl rand -hex 16 > ${CA_DIR}/serial
  openssl ecparam -genkey -name secp256r1 -out ${CA_DIR}/private/${1}key.pem
  openssl req -new -sha256 \
              -key ${CA_DIR}/private/${1}key.pem \
              -out ${CA_DIR}/csr/${1}csr.pem \
              -subj '/C=US/ST=Oregon/L=Portland/CN=www.'${1}'.com'
  openssl ca ${CA_EXTRA} -batch -enddate 99991231235959Z \
              -in ${CA_DIR}/csr/${1}csr.pem \
              -out ${CA_DIR}/${1}cert.pem
}


# Creates files and directories
mkdir -p certs crl newcerts private csr
touch ${CA_DIR}/index.txt ${CA_DIR}/index.txt.attr

# Creates CERTS (order matters)
for i in ca server client ; do create_cert $i; done

chmod -R 755 ${CA_DIR}
