#!/bin/sh -e

CA_DIR=${1:-/etc/raddb/certs}

# Constructs a WISUN-IDEV certificate chain
# Note: the CA cert doe not need to have the end date of 99991231235959Z
# 1 - config file
# 2 - certificate name
# 3 - CA cert ; if not present is a self signing
# 4 - LAST; indicates is the end of chain
create_cert () {
  export OPENSSL_CONF=${1}
  export subjectAltName=email:postmaster@htt-consult.com
  export hwType=''
  export hwSerialNum=''

  local CRT=${2}
  local SIGNING_CRT=${3}
  local EXTRA=""
  local DEVICE=''
  local SUBJ='/C=US/ST=Oregon/L=Portland/CN=www.'${CRT}'.com'

  if [ $# -eq 2 ]
  then
    # This is our CA
    EXTRA="-extensions v3_ca -selfsign "
  else
    EXTRA="-cert ${CA_DIR}/${3}.crt.pem -keyfile ${CA_DIR}/private/${3}.key.pem"
  fi

  if [ $# -eq 3 ]
  then
    # This is an intermediate certificate
    # append to extra
    EXTRA="-extensions v3_ca ${EXTRA}"
  fi

  if [ $# -eq 4 ]
  then
    # This is a device
    DEVICE="-extensions 8021ar_idevid"
    SUBJ='/'
    # some HW TYPE
    export hwType=1.3.6.1.4.1.6715.10.1
     # Some hex
    export hwSerialNum=01020304
    export subjectAltName="critical,otherName:1.3.6.1.5.5.7.8.4;SEQ:hmodname"
  fi
  openssl rand -hex 16 > ${CA_DIR}/serial
  openssl ecparam -genkey -name prime256v1 -out ${CA_DIR}/private/${CRT}.key.pem
  openssl req -new -sha256 \
              -key ${CA_DIR}/private/${CRT}.key.pem \
              -out ${CA_DIR}/csr/${CRT}.csr.pem \
              -subj ${SUBJ}
  openssl ca ${DEVICE} ${EXTRA} -batch -enddate 99991231235959Z -notext \
              -in ${CA_DIR}/csr/${CRT}.csr.pem \
              -out ${CA_DIR}/${CRT}.crt.pem
}

get_cert_by_name () {
  echo ${CA_DIR}/${1}.crt.pem
}

# 1 - chain name
# 2 - crt name
concatenate_crt() {
  cat $(get_cert_by_name ${2}) >> ${1}
}

# Creates files and directories
cd ${CA_DIR}
mkdir -p certs crl newcerts private csr
touch ${CA_DIR}/index.txt ${CA_DIR}/index.txt.attr

# Creates CA CRT (order matters)
create_cert ${CA_DIR}/openssl.cnf ca

# Declare chains names
# chains strings with trailing space
c1="1-1 1-2 1-3 server "
c2="2-1 2-2 2-3 client "

# Loop through
for index in 1 2 ; do
  # First cert is signed by CA
  # Remaind certs are signed by previous cert
  SIGNING_CRT=ca
  # chain is redeclared as an array
  eval chain=\$c${index}
  unset LAST

  for CRT in ${chain} ; do
    if [ "${CRT}" = "${chain##* }" ] ; then
      LAST="DEVICE"
    fi
    create_cert ${CA_DIR}/openssl-8021AR-wisun.cnf ${CRT} ${SIGNING_CRT} ${LAST}
    SIGNING_CRT=${CRT}
  done

  # Chain must be created from bottom(first) up(last)
  REVERSE=$(echo "${chain}" | ( while read -d ' ' f;do g="$f${g+ }$g" ;done;echo "$g" ))
  for CRT in ${REVERSE} ; do
    concatenate_crt ${SIGNING_CRT}-chain.pem ${CRT}
  done
done

chmod -R 755 ${CA_DIR}
