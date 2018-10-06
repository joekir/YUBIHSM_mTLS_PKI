## Running/building

```
$ ./build.sh
```

## Example query

```
# to get the IP it's running on
$ docker inspect <container ID> 

# The noverify, is because we're using a TLS reverse proxy instead of the VA signing keys
$ openssl ocsp -sha256 -noverify -issuer client-root-ca.pem -cert client-intermediate-ca-2.pem -url http://<CONTAINER IP ADDR>:11080
```
