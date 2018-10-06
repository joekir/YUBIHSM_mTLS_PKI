#!/bin/bash
set -eu

CSR_IN=../Intermediates/client-intermediate-ca-$INT_CA_NUM/tmp/client-intermediate-ca-$INT_CA_NUM.csr
CERT_OUT=../Intermediates/client-intermediate-ca-$INT_CA_NUM/certs/client-intermediate-ca-$INT_CA_NUM.pem

pushd ../ > /dev/null

openssl ca -engine pkcs11 -keyform engine -config configs/client-root-ca.conf -in $CSR_IN -out $CERT_OUT -extensions sub_ca_ext

# remove the text output so it's just a PEM (annoyingly the CA function doesn't have a flag for that..)
openssl x509 -in $CERT_OUT -out $CERT_OUT 

rm $CSR_IN
popd  > /dev/null
