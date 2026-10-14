# AKS Bootstrap Module (Argo CD — Minimal Terraform Footprint)

Terraform module that bootstraps an AKS cluster with **only Argo CD**. All other in-cluster resources are managed by Argo CD via GitOps.

## Design Principle

> **Terraform installs ONLY Argo CD. Argo CD manages EVERYTHING else inside the cluster.**

### Why?

| Concern | Terraform | Argo CD |
|---------|-----------|---------|
| Drift Detection | Only on plan/apply | Continuous (every 3 min) |
| Self-healing | No | Auto-syncs to desired state |
| K8s resource mgmt | Not designed for it | Built for it |
| Conflict risk | Terraform vs Argo fight | Single owner per resource |
| Rollback | Complex | Git revert = rollback |

### Terraform's Responsibilities Inside the Cluster

```text
1. argocd namespace          ← Only namespace Terraform creates
2. Argo CD Helm chart        ← Only Helm release Terraform manages
3. App of Apps manifest      ← Single entry point for GitOps

# Argo CD's Responsibilities (via GitOps Repo)

├── ingress-nginx
├── cert-manager
├── prometheus + grafana
├── external-secrets
├── namespaces
├── RBAC policies
├── service accounts
├── network policies
├── CRDs
└── all application manifests

# Architecture:

Terraform                          Argo CD (GitOps)
─────────                          ────────────────
                                   
Install Argo CD ──► App of Apps ──► Git Repo
                                     ├── apps/
                                     │   ├── ingress-nginx.yaml
                                     │   ├── cert-manager.yaml
                                     │   ├── prometheus-stack.yaml
                                     │   └── external-secrets.yaml
                                     └── overlays/
                                         ├── dev/
                                         ├── test/
                                    
                                    
##Post-Deployment
Access Argo CD UI

# Port forward
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d

# Open browser → https://localhost:8080
# Username: admin

