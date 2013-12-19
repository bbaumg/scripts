#!/bin/bash
echo -n "Set a name for the certificate [ENTER]: "
read v_keyname
openssl genrsa -out /etc/pki/tls/private/$v_keyname.key 1024
openssl req -new -key /etc/pki/tls/private/$v_keyname.key -out /etc/pki/tls/private/$v_keyname.csr
openssl x509 -req -days 365 -in /etc/pki/tls/private/$v_keyname.csr -signkey /etc/pki/tls/private/$v_keyname.key -out /etc/pki/tls/certs/$v_keyname.crt
echo ""
echo "SSLCertificateFile /etc/pki/tls/private/$v_keyname.key"
echo "SSLCertificateKeyFile /etc/pki/tls/certs/$v_keyname.crt"
