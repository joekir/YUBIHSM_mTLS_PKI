# YubiHSM2

## Intro

### What the HSM will be responsible for

1. Generating and storing the private key for the root Certificate Authority (CA)
2. Signing the CSR for the intermediate CAs  
3. Signing a CRL and OCSP revocation list for intermediate CAs

### Algorithm choices

- RSA PSS SHA256 for the signature (I would like to use ED25519 but I'm unsure if dependant components would support)
- Using a 4096 bit RSA key

## YubiHSM Setup 

**I CANNOT STRESS THIS POINT MORE BOLDLY!!!!!!!!!1111ELEVENTY**
*IFF you utterly f**ck this up, the only way to reset is as follows:*

> "To physically reset the YubiHSM 2 insert the device while holding the touch sensor for 10 seconds"

**You must** create a [udev rule](https://developers.yubico.com/YubiHSM2/Component_Reference/yubihsm-connector/) for this to work, to do this just copy the full directory listing from the ruleset located in this folder to `/etc`.

1. **Setup the connector**
    ```
    # cd connector
    # yubihsm-connector -c yubihsm-connector-config.yaml -d
    ```
    
    Navigate to http://127.0.0.1:47589/connector/status in a browser
    It should return:
    ```
    status=OK
    serial=0007040527
    version=1.0.1
    pid=18703
    address=127.0.0.1
    port=47589
    ```
    *we aren't really concerned about the SSL certifiate to this as it's on a device with no network connection anyway*
    
2. **Provisioning the Auth and Wrap Keys in the HSM**

    ```
    $ yubihsm-shell -C `grep -o '127.*' connector/yubihsm-connector-config.yaml`
    ```

    Assuming this is a fresh reset YubiHSM2 where the default password is 'password' (it's stored at key_id:1)
    **This default will be removed as part of this flow.**
    
    You will need to know in advance
    - `$AUDIT_PASS` - this is a password which we will use to review the audit trail on the HSM
    - `$Prod_PKCS11_PASS` - Production password for libpkcs11 to access the HSM
    - `$Prod_AESCCM_wrapkey` - Key to allow backup of production asymmetric keys
    - `$Stage_PKCS11_PASS` - Staging password for libpkcs11 to access the HSM
    - `$Stage_AESCCM_wrapkey` - Key to allow backup of staging asymmetric keys

    See [Backup and Restore](https://developers.yubico.com/YubiHSM2/Backup_and_Restore/) for more details on Wrap Keys.
 
    ```
    yubihsm> connect
    yubihsm> session open 1 password
    Created session 0

    # Session Number can be anything it want's so let $SESS_NUM=0 in this example, but it may be different when you run it
     
    # new auth key for auditing, get your $AUDIT_PASS
    yubihsm> put authkey $SESS_NUM 0x0005 "Audit auth key" all audit none
    Enter password:
    Stored Authentication key 0x0005
    
    # Prod PKCS11 key
    yubihsm> put authkey $SESS_NUM 0x0006 "Production PKCS11 Auth Key" 1 delete_asymmetric:asymmetric_gen:asymmetric_sign_pkcs:asymmetric_sign_pss:export_wrapped:import_wrapped asymmetric_sign_pkcs:asymmetric_sign_pss:export_under_wrap
    Enter password:
    Stored Authentication key 0x0006
    
    # Stage PKCS11 key (note it's in a separate physical domain 2)
    yubihsm> put authkey $SESS_NUM 0x000a "Staging PKCS11 Auth Key" 2 delete_asymmetric:asymmetric_gen:asymmetric_sign_pkcs:asymmetric_sign_pss:export_wrapped:import_wrapped asymmetric_sign_pkcs:asymmetric_sign_pss:export_under_wrap
    Enter password:
    Stored Authentication key 0x000a
    
    # Prod Wrap Key 
    yubihsm> put wrapkey $SESS_NUM 0x0007 "Production Wrap Key" 1 export_wrapped:import_wrapped asymmetric_sign_pkcs:asymmetric_sign_pss:export_under_wrap $Prod_AESCCM_wrapkey
    
    Stored Wrap key 0x0007
 
    # Stage Wrap Key 
    yubihsm> put wrapkey $SESS_NUM 0x000b "Staging Wrap Key" 2 export_wrapped:import_wrapped asymmetric_sign_pkcs:asymmetric_sign_pss:export_under_wrap $Stage_AESCCM_wrapkey
    
    Stored Wrap key 0x000b

    # Check what you have, should be similar the following
    yubihsm> list objects 0
    Found 6 object(s)
    id: 0x0001, type: authkey, sequence: 2
    id: 0x0005, type: authkey, sequence: 0
    id: 0x0006, type: authkey, sequence: 0
    id: 0x0007, type: wrapkey, sequence: 0
    id: 0x000a, type: authkey, sequence: 0
    id: 0x000b, type: wrapkey, sequence: 0
   
    # To get specific details on one of the keys do the following e.g. the staging wrap key (0x000b)
    yubihsm> get objectinfo $SESS_NUM 0x000b wrapkey
    id: 0x000b, type: wrapkey, algorithm: aes256-ccm-wrap, label: "Staging Wrap Key", length: 40, domains: 2, sequence: 0, origin: imported, capabilities: export_wrapped:import_wrapped, delegated_capabilities: asymmetric_sign_pkcs:asymmetric_sign_pss:export_under_wrap
 
    # Tidy up!
    
    # Syntax: delete <session> <id> <object type>
    # Delete the god key! (default "password" key with access to *all* domains)
    yubihsm> delete $SESS_NUM 1 authkey
    
    # enable forced audits
    yubihsm> put option $SESS_NUM force_audit 01
    ```

    More details - [YubiHSM2 - PutAuthkey](https://developers.yubico.com/YubiHSM2/Commands/Put_Authkey.html)

3. **Generating the root CA keys**

    Production Root CA
    ```
    $ yubihsm-shell -C `grep -o '127.*' connector/yubihsm-connector-config.yaml` -a generate-asymmetric -A rsa4096 -c export_under_wrap,asymmetric_sign_pkcs,asymmetric_sign_pss -l "production_root_CA" --wrap-id 0x0007 --keyset 0x0006 -d1 -t asymmetric
    ```

    Staging Root CA
    ```
    $ yubihsm-shell -C `grep -o '127.*' connector/yubihsm-connector-config.yaml` -a generate-asymmetric -A rsa4096 -c export_under_wrap,asymmetric_sign_pkcs,asymmetric_sign_pss -l "staging_root_CA" --wrap-id 0x000b --keyset 0x000a -d 2 -t asymmetric
    ```
    
    More details - [YubiHSM2 - PKCS11](https://developers.yubico.com/YubiHSM2/Component_Reference/PKCS_11/)

4. **The PKCS#11 OpenSSL Engine part**

    - Install `libengine-pkcs11-openssl` (the Dockerfile already has all these dependencies added)
    - Follow the steps in the CA creation [instructions for the ROOT CA](../Docs/Root_CA.md)

## Clearing the Audit logs

**As we've enabled `Force Audit mode` this means that the log buffer will not wrap, it can only be manually cleared.**
This is to ensure an adversary cannot cloak a key tamper with `no-op` commands. There are only 62 different log entries available.
Hence we must check and clear it after/before usage ([Yubico details](https://developers.yubico.com/YubiHSM2/Concepts/Logs.html)).

```
# reviewing logs
yubihsm> get deviceinfo
Version number:         2.0.0
Serial number:          7040527
Log used:               13/62
...

yubihsm> audit get 1
0 unlogged boots found
0 unlogged authentications found
Found 24 items
item:     1 -- cmd: 0xff -- length: 65535 -- session key: 0xffff -- target key: 0xffff -- second key: 0xffff -- result: 0xff -- tick: 4294967295 -- hash: 84568684474b8235a9aecd4e2849ec76
item:     2 -- cmd: 0x00 -- length:    0 -- session key: 0xffff -- target key: 0x0000 -- second key: 0x0000 -- result: 0x00 -- tick: 0 -- hash: d861bc8935dd42afbf471d6869d488bc
item:     3 -- cmd: 0x03 -- length:   10 -- session key: 0xffff -- target key: 0x0001 -- second key: 0xffff -- result: 0x83 -- tick: 844 -- hash: ff00c7cff06fb1e05e57fb302d6b64f7
...
...

# To clear the logs, we set the current index ptr to the last in the list above, e.g. 24

yubihsm> audit set 1 24
yubihsm> audit get 1
0 unlogged boots found
0 unlogged authentications found
Found 1 item
item:    25 -- cmd: 0x67 -- length:    2 -- session key: 0x0005 -- target key: 0xffff -- second key: 0xffff -- result: 0xe7 -- tick: 28306 -- hash: 340977ecffe1803e50e3d6dc76115feb
```

## Backup and restore

#### Backup (this is the staging group...)
```
$ yubihsm-setup -c `grep -o '127.*' connector/yubihsm-connector-config.yaml` -k 0x000a dump
Enter authentication password: <redacted>
Using authentication key 0x000a
Enter the wrapping key ID to use for exporting objects: 0x000b
Found 5 object(s)
Unable to export object Authkey with ID 0x0001: Wrong premissions for operation. Skipping over ...
Unable to export object Authkey with ID 0x0005: Wrong premissions for operation. Skipping over ...
Unable to export object Authkey with ID 0x000a: Wrong premissions for operation. Skipping over ...
Unable to export object Wrapkey with ID 0x000b: Wrong premissions for operation. Skipping over ...
Successfully exported object Asymmetric with ID 0xce1e to ./0xce1e.yhw
All done
```

See [here](https://developers.yubico.com/YubiHSM2/Backup_and_Restore/) for how to load a wrap key

#### Restore
```
$ yubihsm-shell -C `grep -o '127.*' connector/yubihsm-connector-config.yaml` -a put-wrapped --in=0xce1e.yhw --keyset 0x000a --wrap-id 0x000b
Session keepalive set up to run every 15 seconds
Enter password:
Created session 0
Object imported as 0xce1e of type asymmetric
```
