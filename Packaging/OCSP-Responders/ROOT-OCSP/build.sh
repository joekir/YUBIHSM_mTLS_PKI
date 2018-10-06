#!/bin/sh

set -eu

HOST_OCSP_BASE=`readlink -f ../../../ROOT`

# cleanup old crap
#docker rmi -f $(docker images -f "dangling=true" -q)

cp $HOST_OCSP_BASE/db/* db/
cp $HOST_OCSP_BASE/certs/client-root-ca.pem certs/

docker build -t production_ocsp_root:latest .
