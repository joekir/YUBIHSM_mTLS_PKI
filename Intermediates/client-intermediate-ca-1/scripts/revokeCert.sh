#!/bin/bash
set -eu

echo "INT_CA_NUM set to $INT_CA_NUM"

pushd ../ > /dev/null

echo "what certificate from the certs directory would you like to revoke?"
read certname

if [ -z "$certname" ]; then
	echo "please specify a certificate name!"
	exit 1
fi

if [ ! -f certs/$certname ]; then
	echo "Certificate $certname was not found in certs directory!"
	exit 1
fi

echo "What is the reason for the revocation? (unspecified, keyCompromise, CACompromise, affiliationChanged, superseded, cessationOfOperation, certificateHold, removeFromCRL)"
read reason
if [ -z "$reason" ]; then
	echo "no reason specified!"
	exit 1
fi

openssl ca -config configs/client-intermediate-ca.conf -revoke certs/$certname -crl_reason $reason 

popd  > /dev/null
