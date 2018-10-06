FROM alpine:3.7 

# compact layers
RUN apk update && apk upgrade && apk add openssl && adduser -s /bin/bash -u 1000 -D -H -S docker && mkdir -p /pki

COPY $PWD /pki

RUN chown -R docker:root /pki
USER docker
WORKDIR /pki

CMD ./runOCSPResponder.sh
