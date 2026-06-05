# Kubernetes manifests — Northwind Bank

Self-contained manifests for running the app in any Kubernetes cluster (minikube, kind, k3d, Docker Desktop, or a real cluster).

## Files

| File | Purpose |
|------|---------|
| `00-namespace.yaml`              | `bank` namespace |
| `10-postgres-secret.yaml`        | DB credentials + `DATABASE_URL` |
| `11-postgres-init-configmap.yaml`| Embedded `init.sql` + `seed.sql` mounted into Postgres' init dir |
| `12-postgres-statefulset.yaml`   | Postgres 16 StatefulSet + headless Service + 1Gi PVC |
| `20-backend.yaml`                | Express API Deployment + ClusterIP Service |
| `30-frontend.yaml`               | Nginx (static React + `/api` proxy) Deployment + Service |
| `40-ingress.yaml`                | Optional Ingress at `bank.local` |

## Build the images

The Deployments reference `bank-backend:latest` and `bank-frontend:latest` with `imagePullPolicy: IfNotPresent`, so they work without a registry on local clusters.

```powershell
# From repo root
docker build -t bank-backend:latest  ./backend
docker build -t bank-frontend:latest -f ./frontend/Dockerfile.prod ./frontend
```

Then load the images into your local cluster:

```powershell
# minikube
minikube image load bank-backend:latest
minikube image load bank-frontend:latest

# kind
kind load docker-image bank-backend:latest
kind load docker-image bank-frontend:latest

# Docker Desktop Kubernetes: images are already visible, nothing to load
```

## Deploy

```powershell
kubectl apply -f k8s/
```

Watch it come up:

```powershell
kubectl -n bank get pods -w
```

## Access the app

Pick one:

**Port-forward (simplest):**

```powershell
kubectl -n bank port-forward svc/frontend 8080:80
```

Open http://localhost:8080.

**Ingress:** apply `40-ingress.yaml`, point `bank.local` at your ingress controller IP in your hosts file, then open http://bank.local.

## Tear down

```powershell
kubectl delete namespace bank
```

This also removes the Postgres PVC.
