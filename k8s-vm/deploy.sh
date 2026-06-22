#!/bin/sh
# Deploy the bank app VMs into a given namespace.
#
# Usage: ./deploy.sh <namespace>
#
# The namespace must already exist and be a VM Operator (Supervisor) namespace
# with a VirtualMachineClass, VirtualMachineImage, and StorageClass associated.
# None of the manifests hard-code a namespace; it's supplied here via `-n`.

set -eu

NS="${1:-}"
if [ -z "$NS" ]; then
    echo "Usage: $0 <namespace>" >&2
    exit 1
fi

# Run relative to this script's directory so it works from any cwd.
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

for f in \
    05-dns.yaml \
    10-postgres-vm.yaml \
    20-backend-vm.yaml \
    30-frontend.yaml \
    40-ingress.yaml
do
    echo "Applying $f into namespace $NS..."
    kubectl -n "$NS" apply -f "$DIR/$f"
done

echo "Done. Watch progress with: kubectl -n $NS get vm,vmservice,deploy,svc"
