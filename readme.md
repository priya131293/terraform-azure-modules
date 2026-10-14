# Terraform Azure Infrastructure Modules

Production-ready Terraform modules for Azure infrastructure with GitOps (Argo CD) approach.

## Architecture

```text
┌──────────────────────────────────────────────────────────┐
│              TERRAFORM MANAGES (Azure Infra)              │
│                                                          │
│  Module 1: resourcegroup/                                │
│  Module 2: vnet/                                         │
│  Module 3: aks/                                          │
│  Module 4: aks_bootstrap/ (ONLY Argo CD)                 │
│                                                          │
└──────────────────────────────────────────────────────────┘
                         │
                         ▼
┌──────────────────────────────────────────────────────────┐
│              ARGO CD MANAGES (In-Cluster)                 │
│                                                          │
│  ingress-nginx, cert-manager, prometheus, grafana,       │
│  external-secrets, namespaces, RBAC, CRDs, apps          │
└──────────────────────────────────────────────────────────┘