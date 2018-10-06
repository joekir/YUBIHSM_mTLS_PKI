#!/bin/sh

set -eu

# use the -u flag to force the check to fail
echo "HOST_OCSP_BASE set to $HOST_OCSP_BASE"
echo "INT_NUM_CA set to $INT_NUM_CA"

# clean previous setup
find certs -type f \( ! -iname ".*" ! -iname "junk*" \) -print0 | xargs -0 rm -f --
find db -type f -not -iname ".*" -print0 | xargs -0 rm -f --

cp $HOST_OCSP_BASE/db/* db/
cp $HOST_OCSP_BASE/certs/client-intermediate-ca-$INT_NUM_CA.pem certs/
#cp $HOST_OCSP_BASE/../ROOT/certs/client-root-ca.pem certs/ 

rm -f runOCSPResponder.sh
echo "#!/bin/sh\nset -eu\nopenssl ocsp -port 11081 -req_text -rsigner certs/junk.pem -rkey private/junk.key -index db/index -CA certs/client-intermediate-ca-$INT_NUM_CA.pem -ignore_err" > runOCSPResponder.sh
chmod 0555 runOCSPResponder.sh

docker build -t production_ocsp_int$INT_NUM_CA:latest .

# cleanup old crap
#docker rmi -f $(docker images -f "dangling=true" -q)
