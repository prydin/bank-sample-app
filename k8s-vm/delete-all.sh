#!/bin/sh

set -eu

NS="${1:-}"
if [ -z "$NS" ]; then
    echo "Usage: $0 <namespace>" >&2
    exit 1
fi

DNS_VIP=10.1.8.133

# Run relative to this script's directory so it works from any cwd.
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

for f in \
    05-dns.yaml \
    10-postgres-vm.yaml \
    20-backend-vm.yaml \
    30-frontend.yaml \
    40-ingress.yaml
do
    echo "Deleting $f from namespace $NS..."
    envsubst < "$DIR/$f" | kubectl -n "$NS" delete -f -
done