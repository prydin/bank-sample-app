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

export NS
export DNS_VIP=10.1.8.133

# Run relative to this script's directory so it works from any cwd.
DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

for f in \
    05-secrets.yaml 
do
    echo "Applying $f into namespace $NS..."
    envsubst < "$DIR/$f" '$NS $DNS_VIP' | kubectl -n "$NS" apply -f -
done

cd terraform
terraform init
terraform plan -state=~/.terraform/terraform.tfstate
terraform apply -auto-approve -state=~/.terraform/terraform.tfstate

echo "Done. Watch progress with: kubectl -n $NS get vm,vmservice,deploy,svc"
