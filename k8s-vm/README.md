# Northwind Bank on VMware VM Operator VMs

Same app, but the **backend** and **database** run inside [VMware VM Operator](https://vm-operator.readthedocs.io/) `VirtualMachine`s (Fedora cloud image, bootstrapped via cloud-init). The **frontend** still runs as a regular pod.

## Prerequisites

- A Kubernetes cluster with VM Operator running. In practice this means **vSphere with Tanzu (vSphere Supervisor)** in vSphere 7.0+, where VM Operator is installed and managed by VMware. Standalone deployment of VM Operator on a non-vSphere cluster is not a supported configuration.
- A Supervisor namespace (`bank-vm` in these manifests) that has at least one published `VirtualMachineClass`, `VirtualMachineImage`, and `StorageClass` associated with it.
- Optional: an ingress controller for the frontend's `Ingress`.

Verify VM Operator is healthy and discover what is available in your namespace:

```powershell
kubectl api-resources --api-group=vmoperator.vmware.com
kubectl -n bank-vm get vmclass
kubectl -n bank-vm get vmimage
kubectl get storageclass
```

## Files

| File | Purpose |
|------|---------|
| `00-namespace.yaml`     | `bank-vm` namespace |
| `10-postgres-vm.yaml`   | Postgres `VirtualMachine` + `VirtualMachineService` + bootstrap `Secret` (cloud-init installs postgresql-server and seeds the DB) |
| `20-backend-vm.yaml`    | Node.js backend `VirtualMachine` + `VirtualMachineService` + bootstrap `Secret` (cloud-init installs nodejs, writes the Express app, runs it under systemd) |
| `30-frontend.yaml`      | Nginx frontend `Deployment` + `Service` (same `bank-frontend:latest` image as `k8s/`) |
| `40-ingress.yaml`       | Optional `Ingress` at `bank-vm.local` |

## Pick a class, image, and storage class

Both VM manifests reference these placeholder values:

```yaml
spec:
  className: best-effort-small
  imageName: vmi-fedora-40
  storageClass: wcpglobal-storage-profile
```

Replace each one with a value that exists in your Supervisor namespace:

```powershell
# Find a class (CPU/memory shape)
kubectl -n bank-vm get vmclass

# Find a Fedora 40 (or other cloud-init-capable Linux) image
kubectl -n bank-vm get vmimage

# Find a storage class associated with the namespace
kubectl get storageclass
```

The image needs Cloud-Init pre-installed (every modern Fedora / Ubuntu / Photon / AlmaLinux cloud image does). The `runcmd` block assumes a Fedora/RHEL-family layout (`dnf`, `/var/lib/pgsql`, `postgresql-setup`); on Ubuntu/Debian images you would need to adjust the `runcmd` and package names.

## Build the frontend image

The frontend container is reused from the regular k8s setup. From the repo root:

```powershell
docker build -t bank-frontend:latest -f ./frontend/Dockerfile.prod ./frontend
```

Push it to a registry your Supervisor can pull from and update the `image:` field in [30-frontend.yaml](30-frontend.yaml) accordingly.

## Deploy

```powershell
kubectl apply -f k8s-vm/
```

Watch the VMs come up:

```powershell
kubectl -n bank-vm get vm,vmservice
kubectl -n bank-vm describe vm postgres
kubectl -n bank-vm describe vm backend
```

First boot is slow — the OS image clone runs, then cloud-init installs packages and seeds the DB. Expect a few minutes before the API is reachable. Re-check readiness:

```powershell
kubectl -n bank-vm exec deploy/frontend -- wget -qO- http://backend:4000/api/health
```

## Access the app

```powershell
kubectl -n bank-vm port-forward svc/frontend 8080:80
```

Open http://localhost:8080.

## Useful VM Operator commands

```powershell
# VM details, IP, conditions, power state
kubectl -n bank-vm get vm
kubectl -n bank-vm get vm postgres -o yaml | less

# Get a web console session (returns a one-time URL)
kubectl -n bank-vm apply -f - <<'EOF'
apiVersion: vmoperator.vmware.com/v1alpha5
kind: VirtualMachineWebConsoleRequest
metadata:
  name: postgres-console
  namespace: bank-vm
spec:
  name: postgres
EOF
kubectl -n bank-vm get virtualmachinewebconsolerequest postgres-console -o yaml

# Power-cycle (re-runs cloud-init, re-seeds the DB)
kubectl -n bank-vm patch vm postgres --type=merge -p '{"spec":{"powerState":"PoweredOff"}}'
kubectl -n bank-vm patch vm postgres --type=merge -p '{"spec":{"powerState":"PoweredOn"}}'

# Or trigger an in-guest restart
kubectl -n bank-vm patch vm postgres --type=merge -p '{"spec":{"nextRestartTime":"now"}}'
```

## Notes & limitations

- **Bootstrap on every fresh VM.** cloud-init only runs once per instance — it does not re-run on a normal power cycle of the *same* VM. To re-seed the database from scratch, delete and recreate the VM (or its underlying disk), not just power-cycle it.
- **Storage.** The OS disk is provisioned from the chosen `VirtualMachineImage` and `StorageClass`. The database lives on that disk. For real persistence across redeploys, attach a PVC under `spec.volumes` and point `PGDATA` at it.
- **First boot is slow.** `dnf` runs at first boot to install Postgres / Node. For production you'd bake a custom image with everything pre-installed.
- **DNS & networking.** A `VirtualMachineService` creates a backing Kubernetes `Service` + `Endpoints`, so the VMs are reachable from pods (and from each other) at `postgres.bank-vm.svc.cluster.local` and `backend.bank-vm.svc.cluster.local`, just like normal pod services.
- **API version.** Manifests use `vmoperator.vmware.com/v1alpha5`. Earlier vSphere releases ship `v1alpha2`/`v1alpha3`/`v1alpha4`; the schema used here (`spec.className`, `spec.imageName`, `spec.storageClass`, `spec.bootstrap.cloudInit.rawCloudConfig`, `spec.powerState`) is compatible with all of them — only the `apiVersion:` line needs to change.
- **Frontend stays a pod** — only the backend and database were moved to VMs as requested.
