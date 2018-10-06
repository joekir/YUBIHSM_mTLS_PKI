# Client Certificates

### Creating a new client certificate 

We are using a random 16 byte (128 bit) string for CN. 
This is then "minted" into a certificate signed by an Intermediate Certificate Authority. 


```bash
$ cd Licenses
$ ./create_license_request.sh `openssl rand -hex 16` 
  # This will output a `.key` and a `.csr` file in the local `tmp` folder
  # Now choose an intermediate CA number 'n'

$ cd ../Intermediates/client-intermediate-ca-n/scripts/
$ ./signClient_csr.sh 
```

You will be prompted for the absolute path to your CSR, e.g. `/tmp/<license key>.csr` and your private key e.g. `/tmp/private.pem`

It will give you the location that it outputs the client certificate to, the contents of which are as follows:
1. client public certificate
2. intermediate CA public certificate
3. client private key

**As the file created will contain a private key, caution should be taken in transit**
