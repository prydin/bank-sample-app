# Northwind Bank on KubeVirt VMs

Same app, but the **backend** and **database** run inside KubeVirt `VirtualMachine`s (Fedora 40 cloud image, bootstrapped via cloud-init). The **frontend** still runs as a regular pod.

## Prerequisites

- A Kubernetes cluster with the [KubeVirt](https://kubevirt.io) operator installed and ready.
  - Quick install: see https://kubevirt.io/quickstart_minikube/ or https://kubevirt.io/quickstart_kind/.
- The cluster nodes must support nested virtualization (or run KubeVirt in emulation mode via `useEmulation: true` on the KubeVirt CR — fine for demos, slow).
- Optional: `virtctl` for shelling into VMs.

Verify KubeVirt is healthy:

```powershell
kubectl get kubevirt -n kubevirt
kubectl -n kubevirt get pods
```

## Files

| File | Purpose |
|------|---------|
| `00-namespace.yaml`     | `bank-vm` namespace |
| `10-postgres-vm.yaml`   | Postgres `VirtualMachine` + Service (cloud-init installs postgresql-server, applies schema + seed) |
| `20-backend-vm.yaml`    | Node.js backend `VirtualMachine` + Service (cloud-init installs nodejs, writes Express app, runs it under systemd) |
| `30-frontend.yaml`      | Nginx frontend Deployment + Service (same `bank-frontend:latest` image as `k8s/`) |
| `40-ingress.yaml`       | Optional Ingress at `bank-vm.local` |

## Build the frontend image

The frontend container is reused from the regular k8s setup. From the repo root:

```powershell
docker build -t bank-frontend:latest -f ./frontend/Dockerfile.prod ./frontend
```

Load it into your local cluster (minikube/kind) as described in [../k8s/README.md](../k8s/README.md).

## Deploy

```powershell
kubectl apply -f k8s-vm/
```

Watch the VMs come up:

```powershell
kubectl -n bank-vm get vm,vmi
kubectl -n bank-vm get pods
```

First boot is slow — Fedora cloud image (~700 MB) is pulled, then cloud-init installs packages and seeds the DB. Expect a few minutes before the API is reachable. Re-check readiness:

```powershell
kubectl -n bank-vm exec deploy/frontend -- wget -qO- http://backend:4000/api/health
```

## Access the app

```powershell
kubectl -n bank-vm port-forward svc/frontend 8080:80
```

Open http://localhost:8080.

## Useful KubeVirt commands

```powershell
# Console into a VM (Ctrl+] to detach)
virtctl -n bank-vm console postgres
virtctl -n bank-vm console backend

# Restart a VM (re-runs cloud-init, re-seeds DB)
virtctl -n bank-vm restart postgres

# Tail cloud-init progress
virtctl -n bank-vm console backend
# then inside the VM:
sudo tail -f /var/log/cloud-init-output.log
sudo systemctl status bank-backend
```

## Notes & limitations

- **Ephemeral storage.** Both VMs use `containerDisk` (read-only base + tmpfs overlay). Every restart loses changes — Postgres reinitializes and reseeds. For persistence, swap the OS disk for a `dataVolume` backed by a PVC (requires CDI).
- **cloud-init runs once per instance.** Restarting the VM (not the VMI) gives a fresh instance and re-runs cloud-init.
- **First boot is slow.** dnf installs run during boot. For production you'd bake a custom image with everything pre-installed.
- **DNS.** Each VMI gets a launcher pod on the cluster network; `postgres` resolves via cluster DNS just like from a normal pod.
- **Frontend stays a pod** — only the backend and database were moved to VMs as requested.
