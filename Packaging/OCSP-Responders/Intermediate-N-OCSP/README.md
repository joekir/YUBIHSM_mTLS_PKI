## Quick Note

The junk.key's that are scattered about are just to satiate the ocsp responder. It has it's own [integrity protection that predates TLS](https://en.wikipedia.org/wiki/Online_Certificate_Status_Protocol), it's not very good, therefore as this infrastructure is for backend mTLS it's recommended to just wrap the responder in normal TLS for integrity.

## Running/building

```
$ HOST_OCSP_BASE=<path to intermediateCA root> INT_NUM_CA=<intermediate CA number> ./build.sh
```

## Testing the responder

Once the docker container is running in a new tab try this out from a folder where you have a client cert, some intermediates and the root cert.

```
$ openssl ocsp -sha256 -noverify -issuer client-intermediate-ca-1.pem -cert <CERT NAME>.pem -url <URL>

<CERT NAME>.pem: good
This Update: Apr  4 16:59:06 2018 GMT

$ openssl ocsp -sha256 -noverify -issuer client-intermediate-ca-2.pem -cert <CERT NAME>.pem -url <URL>

<CERT NAME>.pem: unknown
This Update: Apr  4 16:59:06 2018 GMT

$ openssl ocsp -sha256 -noverify -issuer client-root-ca.pem -cert <CERT NAME>.pem -url <URL>

<CERT NAME>.pem: unknown
This Update: Apr  4 16:59:06 2018 GMT
```
