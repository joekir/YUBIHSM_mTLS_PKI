#!/bin/sh

set -eu

# We are using a TLS reverse proxy in front of this, so we do not need the OCSP signature approach
# But openssl doesn't allow us to neglect adding that

openssl ocsp -port 11081 -req_text -rsigner certs/junk.pem -rkey private/junk.key -index db/index -CA certs/client-root-ca.pem -ignore_err
