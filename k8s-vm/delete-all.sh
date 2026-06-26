#!/bin/sh

set -eu

DNS_VIP=10.1.8.133

# Run relative to this script's directory so it works from any cwd.
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

for f in \
    05-secreets.yaml \
    10-postgres-vm.yaml \
    20-backend-vm.yaml \
    30-frontend.yaml \
    40-services.yaml
do
    echo "Deleting $f..."
    envsubst < "$DIR/$f" | kubectl delete -f -
done
