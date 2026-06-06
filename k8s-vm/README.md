# Northwind Bank on VMware VM Operator VMs

All three tiers — **frontend** (nginx), **backend** (Node.js), and **database** (Postgres) — run inside [VMware VM Operator](https://vm-operator.readthedocs.io/) `VirtualMachine`s (Ubuntu cloud image, bootstrapped via cloud-init). A `VirtualMachineService` of type `LoadBalancer` puts a public VIP in front of the frontend VM.

The VMs do not carry an inlined copy of the app source. cloud-init `git clone`s this repository into each guest and runs the real `db/init.sql` + `db/seed.sql` (Postgres VM), builds the real TypeScript backend with `npm run build` (backend VM), or builds the React SPA with `npm run build` and serves it with nginx (frontend VM).

## Static IPs and name resolution

The VMs sit on a vSphere workload network whose DNS server (`10.1.1.1` in this lab) does not know K8s `Service` names or VM hostnames. To make tier-to-tier communication reliable, each VM has a **static IP** and each VM that needs to call another tier writes a small `/etc/hosts` entry in cloud-init.

| Role     | Static IP        | Hostname        |
|----------|------------------|-----------------|
| frontend | `172.16.203.71`  | `bank-frontend` |
| backend  | `172.16.203.72`  | `bank-backend`  |
| postgres | `172.16.203.73`  | `bank-postgres` |

Assumptions baked into the manifests (change in [10-postgres-vm.yaml](10-postgres-vm.yaml), [20-backend-vm.yaml](20-backend-vm.yaml), [30-frontend.yaml](30-frontend.yaml) if your network differs):

- subnet prefix `/24`
- gateway `172.16.203.1`
- nameserver `10.1.1.1`

Verify against an existing VM with `ip a`, `ip route`, and `resolvectl status`. The static-IP block lives under `spec.network.interfaces[0]` in each `VirtualMachine` and looks like:

```yaml
network:
  hostName: bank-frontend
  interfaces:
    - name: eth0
      addresses: ["172.16.203.71/24"]
      gateway4: 172.16.203.1
      nameservers: ["10.1.1.1"]
```

The frontend VM's cloud-init appends `172.16.203.72 backend` to `/etc/hosts` so `frontend/nginx.conf`'s `proxy_pass http://backend:4000;` resolves. The backend VM's cloud-init appends `172.16.203.73 postgres` so the backend's `DATABASE_URL=postgres://bank:bank@postgres:5432/bankdb` resolves. If you change a VM's IP, update both the static-IP block on that VM **and** the matching `/etc/hosts` entry on the VM that calls it.

## Prerequisites

- A Kubernetes cluster with VM Operator running. In practice this means **vSphere with Tanzu (vSphere Supervisor)** in vSphere 7.0+, where VM Operator is installed and managed by VMware. Standalone deployment of VM Operator on a non-vSphere cluster is not a supported configuration.
- A Supervisor namespace (`bank-vm-h93q9` in these manifests) that has at least one published `VirtualMachineClass`, `VirtualMachineImage`, and `StorageClass` associated with it.
- A LoadBalancer provider in the cluster (NSX, Avi, MetalLB, kube-vip, ...) for the `frontend-lb` `VirtualMachineService`.
- Optional: an ingress controller if you also want to use the `Ingress` in `40-ingress.yaml`.

Verify VM Operator is healthy and discover what is available in your namespace:

```powershell
kubectl api-resources --api-group=vmoperator.vmware.com
kubectl -n bank-vm-h93q9 get vmclass
kubectl -n bank-vm-h93q9 get vmimage
kubectl get storageclass
```

## Files

| File | Purpose |
|------|---------|
| `00-namespace.yaml`     | `bank-vm-h93q9` namespace |
| `10-postgres-vm.yaml`   | Postgres `VirtualMachine` + `VirtualMachineService` + bootstrap `Secret` (cloud-init `apt install`s postgresql, clones the repo, applies `db/init.sql` + `db/seed.sql`) |
| `20-backend-vm.yaml`    | Node.js backend `VirtualMachine` + `VirtualMachineService` + bootstrap `Secret` (cloud-init installs Node 20 from NodeSource, clones the repo, runs `npm install && npm run build`, then starts `node dist/index.js` under systemd) |
| `30-frontend.yaml`      | nginx frontend `VirtualMachine` + `VirtualMachineService` + bootstrap `Secret` (cloud-init installs Node 20 + nginx, clones the repo, runs `npm run build`, copies the `dist/` output into `/usr/share/nginx/html`, and installs `frontend/nginx.conf` which reverse-proxies `/api/` to `backend:4000`) |
| `40-ingress.yaml`       | Optional `Ingress` at `bank-vm-h93q9.local` (routes `/` to the `frontend` Service) |
| `50-loadbalancer.yaml`  | User-facing `VirtualMachineService` of type `LoadBalancer` (`frontend-lb`) that selects the frontend VM on port 80 (HTTP) and 22 (SSH) |

## Pick a class, image, and storage class

All three VM manifests reference these placeholder values:

```yaml
spec:
  className: best-effort-small
  imageName: vmi-0f70942d16a5bd4ed   # noble-server-cloudimg-amd64
  storageClass: vsan-default-storage-policy
```

Replace each one with a value that exists in your Supervisor namespace:

```powershell
# Find a class (CPU/memory shape)
kubectl -n bank-vm-h93q9 get vmclass

# Find an Ubuntu cloud image (these manifests target Ubuntu 22.04 / 24.04 noble)
kubectl -n bank-vm-h93q9 get vmimage

# Find a storage class associated with the namespace
kubectl get storageclass
```

The `runcmd` blocks use **Ubuntu/Debian** conventions (`apt`, `/etc/postgresql/<ver>/main`, NodeSource setup script). To target a Fedora/RHEL image you'd need to swap the package names and config paths.

The VMs need outbound internet to reach `github.com`, `archive.ubuntu.com`, `deb.nodesource.com`, and `registry.npmjs.org` during bootstrap.

## Deploy

```powershell
kubectl apply -f k8s-vm/
```

Watch the VMs come up:

```powershell
kubectl -n bank-vm-h93q9 get vm,vmservice
kubectl -n bank-vm-h93q9 describe vm postgres
kubectl -n bank-vm-h93q9 describe vm backend
kubectl -n bank-vm-h93q9 describe vm frontend
```

First boot is slow — the OS image clone runs, then cloud-init installs packages, clones the repo, and either seeds the DB, builds the backend, or builds the SPA. Expect a few minutes before the app is reachable. Tail progress on a VM via the web console (see below) and watch `/var/log/cloud-init-output.log`.

When the backend is up, validate it via the frontend VM:

```powershell
kubectl -n bank-vm-h93q9 get vmservice
# Then from any host that can reach the workload network:
#   curl http://172.16.203.72:4000/api/health
#   curl http://172.16.203.72:4000/api/accounts
```

> **Note:** the backend has no route registered for `/`. Hitting `http://<backend-vm-ip>:4000/` returns `Cannot GET /` from Express — that's expected, not a bug. Test against `/api/health` or `/api/accounts`. The user-facing entry point is the frontend, served on port 80 via the `frontend-lb` LoadBalancer.

## Access the app

Grab the LoadBalancer's external IP:

```powershell
kubectl -n bank-vm-h93q9 get vmservice frontend-lb
```

Open `http://<EXTERNAL-IP>/` in a browser. The nginx VM serves the React SPA at `/` and reverse-proxies `/api/` to the backend VM.

If no LoadBalancer provider is available, port-forward instead:

```powershell
kubectl -n bank-vm-h93q9 port-forward svc/frontend 8080:80
```

and open http://localhost:8080.

## Useful VM Operator commands

```powershell
# VM details, IP, conditions, power state
kubectl -n bank-vm-h93q9 get vm
kubectl -n bank-vm-h93q9 get vm postgres -o yaml | less

# Get a web console session (returns a one-time URL)
kubectl -n bank-vm-h93q9 apply -f - <<'EOF'
apiVersion: vmoperator.vmware.com/v1alpha5
kind: VirtualMachineWebConsoleRequest
metadata:
  name: postgres-console
  namespace: bank-vm-h93q9
spec:
  name: postgres
EOF
kubectl -n bank-vm-h93q9 get virtualmachinewebconsolerequest postgres-console -o yaml

# Power-cycle (re-runs cloud-init, re-seeds the DB)
kubectl -n bank-vm-h93q9 patch vm postgres --type=merge -p '{"spec":{"powerState":"PoweredOff"}}'
kubectl -n bank-vm-h93q9 patch vm postgres --type=merge -p '{"spec":{"powerState":"PoweredOn"}}'

# Or trigger an in-guest restart
kubectl -n bank-vm-h93q9 patch vm postgres --type=merge -p '{"spec":{"nextRestartTime":"now"}}'
```

## Notes & limitations

- **Source of truth is the git repo.** Bootstrap clones `https://github.com/prydin/bank-sample-app.git`. If you fork or move the repo, update the `git clone ...` URL in `10-postgres-vm.yaml`, `20-backend-vm.yaml`, and `30-frontend.yaml`. Re-run is only triggered on a *fresh* VM (cloud-init runs once per instance), so to pick up new commits you must delete and recreate the VM.
- **`Cannot GET /` on the backend is not an error.** The backend only serves `/api/*` routes. The user-facing UI lives on the frontend VM (port 80) — reach it via the `frontend-lb` LoadBalancer.
- **Storage.** The OS disk is provisioned from the chosen `VirtualMachineImage` and `StorageClass`. The database lives on that disk. For real persistence across redeploys, attach a PVC under `spec.volumes` and point `PGDATA` at it.
- **First boot is slow.** `apt` and `npm install` run at first boot. For production you'd bake a custom image with everything pre-installed and skip the cloud-init `runcmd`.
- **DNS & networking.** Workload DNS does not know K8s `Service` names or VM hostnames, so tier-to-tier traffic goes by static IP via `/etc/hosts` (see the *Static IPs and name resolution* section above). The `VirtualMachineService` resources still produce backing `Service`s, but those `ClusterIP`s are not routable from the workload network.
- **API version.** Manifests use `vmoperator.vmware.com/v1alpha5`. Earlier vSphere releases ship `v1alpha2`/`v1alpha3`/`v1alpha4`; the schema used here (`spec.className`, `spec.imageName`, `spec.storageClass`, `spec.bootstrap.cloudInit.rawCloudConfig`, `spec.powerState`, `spec.network.interfaces`) is compatible with `v1alpha3`+ — only the `apiVersion:` line needs to change for those.
