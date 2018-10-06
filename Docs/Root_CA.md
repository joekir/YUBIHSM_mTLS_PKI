# Root CA

### Creating a Root CA
_This will probably be split into the HSM stuff_

```
$ cd ROOT/scripts
$ ./createRootCA.sh
```

### Revocation of an intermediate CA certificate
Locate the cert PEM in the `certs` directory then run

```
$ cd ROOT/scripts
$ ./revokeCert.sh
```

This will ask you for the location and the revocation reason.

### Running and testing the Root's OCSP responder

In one shell:
```
$ cd ROOT/scripts
$ ./runOCSPResponder.sh
```

In another shell:
```
$ cd ROOT/examples
$ ./queryOCSPResponder.sh
```
