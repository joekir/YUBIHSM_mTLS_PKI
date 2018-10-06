#!/bin/bash

## TODO this will be removed!

set -eu

rm -rf tmp/*
rm -rf certs/*
rm -rf db/*
rm -rf private/*
rm -rf CRLs/*

touch db/index
echo "1001" > db/crlnumber
openssl rand -hex 16 | tr '[:lower:]' '[:upper:]' > db/serial
