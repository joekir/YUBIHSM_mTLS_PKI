#!/bin/bash
set -eux

# set -u will throw so you'll know to set this
# It will take a form like "slot_0-label_foo_root_CA" depending what you defined in the YubiHSM2
echo $YOUR_SLOT_AND_LABEL_NAME

# NOTE: this uses the YubiHSM2 as it's engine, if that isn't running, it won't work

pushd ../ > /dev/null

# This assumes the file (yubihsm_pkcs11.conf) is located in the pushd directory
openssl req -new -config configs/client-root-ca.conf -engine pkcs11 -keyform engine -key $YOUR_SLOT_AND_LABEL_NAME -out tmp/client-root-ca.csr

openssl ca -selfsign -engine pkcs11 -config configs/client-root-ca.conf -keyform engine -in tmp/client-root-ca.csr -out certs/client-root-ca.pem -extensions ca_ext

# strip the text output so we just have a pem
openssl x509 -in certs/client-root-ca.pem -out certs/client-root-ca.pem

# cleanup hex generated cert
find certs -type f -not -name 'client-root-ca.pem' -print0 | xargs -0 rm --

rm -rf tmp/*
popd  > /dev/null
