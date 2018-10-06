#!/bin/bash

set -e

if [ -z $1 ] ; then
	echo "You must provide the the ID you'd like to use for the CN!"
	echo "e.g. ./create_client_certificate_request.sh d0d2d0dd7cda0d9b64341960b4b888bc"
	exit 1
fi

openssl genrsa -out tmp/$1.key.pem
chmod 0400 tmp/$1.key.pem
openssl req -new -key tmp/$1.key.pem -out tmp/$1.csr -subj "/C=<COUNTRY>/O=<ORG>/CN=$1"

printf "\nPlease take your things:\n `readlink -f tmp/$1.key.pem`\n `readlink -f tmp/$1.csr`\nand get them signed by a CA\n"
