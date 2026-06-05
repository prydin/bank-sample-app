# Northwind Bank — Sample App

A small demo banking portal: React + TypeScript frontend, Node.js (Express) backend, and PostgreSQL — all wired up with Docker Compose.

## Stack

- **Frontend:** Vite + React 18 + TypeScript, Tailwind CSS, TanStack Query, React Router, Lucide icons
- **Backend:** Node.js + Express + TypeScript, `pg` driver
- **Database:** PostgreSQL 16 (auto-initialized with schema + mock data)
- **Orchestration:** Docker Compose

## Quick start

Requires Docker Desktop.

```powershell
docker compose up --build
```

Then open:

- Frontend: http://localhost:5173
- Backend API: http://localhost:4000/api/health

To stop and wipe the database volume:

```powershell
docker compose down -v
```

## Project layout

```
sampleapp/
├── docker-compose.yml
├── db/
│   ├── init.sql      # schema
│   └── seed.sql      # mock accounts + transactions
├── backend/          # Express API
└── frontend/         # React app
```

## API

- `GET /api/accounts` — all accounts
- `GET /api/accounts/:id` — single account
- `GET /api/accounts/:id/transactions` — recent transactions for an account
- `GET /api/health` — health check

## Local dev (without Docker)

Each side can be run on the host if you have Node.js 20+ and a running Postgres at `postgres://bank:bank@localhost:5432/bankdb`.

Backend:

```powershell
cd backend
npm install
npm run dev
```

Frontend:

```powershell
cd frontend
npm install
npm run dev
```

The Vite dev server proxies `/api/*` to the backend.

## Notes

- Money is stored as integer cents (`BIGINT`) to avoid floating-point issues.
- No authentication — this is a UI/data demo only.
- Mock data uses relative dates (`NOW() - INTERVAL ...`) so transactions always look recent.

## Kubernetes

Manifests for deploying to a Kubernetes cluster (minikube, kind, Docker Desktop, etc.) live in [k8s/](k8s/). See [k8s/README.md](k8s/README.md) for build and apply steps.

A KubeVirt variant — backend and database run as `VirtualMachine` resources, frontend stays as a pod — lives in [k8s-vm/](k8s-vm/). See [k8s-vm/README.md](k8s-vm/README.md).
