### Docker Setup

```
$ docker build -t licensing:latest .
# cleanup old crap
$ docker rmi -f $(docker images -f "dangling=true" -q)
$ docker run --net="host" -v $PWD:/pki -i -t licensing:latest /bin/bash
```

You'll communicate with HSM via the localhost network on the `yubihsm-connector` running on the host.           
See [YubiHSM2/README.md](../YubiHSM2/README.md) for info.
