# Creating a mTLS PKI backed by s YubicoHSM

From my experience it's a popular security requirement to stipulate backend traffic use mutual-TLS (doesn't actually exist as a concept, it's just TLS with a client certificate..) except that usually devolves to self-signed certs, hence doesn't quite have the revocation benefits of a real PKI.

It's also a slightly different use case from normal PKI for browsers, CRL (Certificate Revocation List) lose lots of their value and OCSP become much more useful.

For most developers a full-blown HSM is too expensive, e.g. Gemalto is $50k a year or something? Whereas a YubiHSM is a one-off purchase of ~ $700. This is much more appealing.

This follows pages 366-376 of [Bulletproof TLS](https://www.feistyduck.com/books/bulletproof-ssl-and-tls/) pretty closely. It's recommended reading.

The accompanying blog post for this repo on [josephkirwin.com](https://www.josephkirwin.com/) will have some extra info on roles in the HSM and dettail 1 or 2 shortcomings.

## Design notes

- The ROOT CA key will be created in the [YubiHSM](https://www.yubico.com/products/yubihsm/) and never leave the HSM
- The ROOT and Intermediate's [OCSP](https://en.wikipedia.org/wiki/Online_Certificate_Status_Protocol) responder will run on a different box(es) that will be updated only if there is an intermediate certificate breach

## Setup

1. [YubiHSM](YubiHSM2/README.md)
2. [Docker Setup](Docs/DockerSetup.md)
3. [Root CA](Docs/Root_CA.md)
4. [Intermediate CA](Docs/Intermediate_CA.md)
5. [Clear those audit logs!](YubiHSM2/README.md#clearing-the-audit-logs)
6. [Client Certificates](Docs/Client_Certificates.md)
