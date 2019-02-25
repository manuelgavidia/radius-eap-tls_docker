# Radius EAP-TLS

A lightweight and fast freeradius eap-tls server to test WISUN authentication.

This image is based on the minimalistic Alpine Linux.

## Build

The following command will build the container, generate the certificates, copy them to host and generate the eapol_test configuration file.

    ./build.sh

This step creates the PKI infrastructure as defined by WISUN, keys are generated without password.

## Test with eapol_test

### Clone and build EAPOL_TEST
    git clone git://w1.fi/hostap.git
    cd hostap/wpa_supplicant
    cp defconfig .config
    make eapol_test

note: if you want the IPV6 version apply [001-IPV6.patch](001-IPV6.patch) first to hostap code.

note: read the hostap documentation and use the default openssl backend in .config

### Start freeradius container
    docker-compose up

### Run test (IPV6)
    ./hostap/wpa_supplicant/eapol_test -c test.conf -a 2001:3200:3200::20 -s test
