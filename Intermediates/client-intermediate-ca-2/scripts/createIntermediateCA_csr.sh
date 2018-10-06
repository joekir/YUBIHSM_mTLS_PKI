#!/bin/bash 
set -eu
 
echo "Create a password for intermediate CA key (must be greater than 4 characters), followed by [ENTER]:" 
read password 
 
if [ -z "$password" ]; then 
        echo "password not set!" 
        exit 1 
fi 

pushd ../ > /dev/null 

CSR_OUT=tmp/client-intermediate-ca-$INT_CA_NUM.csr
KEY_OUT=private/client-intermediate-ca-$INT_CA_NUM.key

openssl req -new -config configs/client-intermediate-ca.conf -passin pass:$password -out $CSR_OUT -keyout $KEY_OUT 

chmod 0600 $KEY_OUT
popd  > /dev/null
