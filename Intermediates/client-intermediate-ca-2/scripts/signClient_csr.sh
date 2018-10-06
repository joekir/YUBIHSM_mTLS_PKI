#!/bin/bash 
set -eu

echo "INT_CA_NUM set to $INT_CA_NUM"

echo "Provide absolute path to client certificate signing request (CSR)"
read certpath

if [ -z "$certpath" ]; then
        echo "path not specified!"
        exit 1
fi

if [ ! -f $certpath ]; then
        echo "$certpath could not be found!"
        exit 1
fi

echo "Provide absolute path to private key file (PEM)"
read PRIVATEKEY

if [ -z "$PRIVATEKEY" ]; then
        echo "path not specified!"
        exit 1
fi

if [ ! -f $PRIVATEKEY ]; then
        echo "$PRIVATEKEY could not be found!"
        exit 1
fi

pushd ../ > /dev/null

LICENSE=tmp/license-`date +"%Y%m%d%H%M%S"`.pem
openssl ca -config configs/client-intermediate-ca.conf -extensions client_ext  -in $certpath -out $LICENSE
# strip the text so we just have a PEM
openssl x509 -in $LICENSE -out $LICENSE

cat certs/client-intermediate-ca-$INT_CA_NUM.pem >> $LICENSE
cat $PRIVATEKEY >> $LICENSE
chmod 0400 $LICENSE

echo "New license written to `readlink -f $LICENSE`"
popd  > /dev/null
