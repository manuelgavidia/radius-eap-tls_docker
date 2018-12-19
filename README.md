# Radius EAP-TLS

A lightweight and fast freeradius eap-tls server. This image is based on the minimalistic Alpine Linux.

## Build and launch

The following command will build, launch the container, generate the certificates and copy them to host.

    ./launch.sh

If in this step is created the PKI infrastructure, use "radius" for the client key or change the password in eapool_template.conf

## Test with eapol_test

### Clone and build the EAPOOL application
    git clone git://w1.fi/hostap.git
    cd hostap/wpa_supplicant
    cp defconfig .config
    make eapol_test

### Run the test

    ./hostap/wpa_supplicant/eapol_test -c test.conf -a 172.26.0.100 -s whatever
