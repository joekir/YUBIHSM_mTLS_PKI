# Intermediate CA

_The following assumes you're in the root directory of the repository_

## Current

You can use this approach to create multiple intermediates, by creating a copy of the directory
and incrementing the `INT_CA_NUM` environment variable

#### Creating a new Intermediate CA 1
```
$ cd Intermediate/scripts
$ INT_CA_NUM=1 ./createIntermediateCA_csr.sh
$ cd ../../ROOT/scripts
$ ./signIntermediateCA_csr.sh
```

#### Signing a client certificate
```
$ cd Intermediate/scripts
$ INT_CA_NUM=1 ./signClient_csr.sh
```
This will ask you for the path to the client CSR file and will out put it to
/tmp/<hex>.pem

#### Revocation of a client certificate
Locate the cert PEM in the `certs` directory then run

```
$ cd Intermediate/scripts
$ INT_CA_NUM=1 ./revokeCert.sh
```

This will ask you for the location and the revocation reason.
