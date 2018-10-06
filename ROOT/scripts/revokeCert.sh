#!/bin/bash
set -eu

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

openssl ca -engine pkcs11 -keyform engine -config configs/client-root-ca.conf -revoke certs/$certname -crl_reason $reason 

popd  > /dev/null

