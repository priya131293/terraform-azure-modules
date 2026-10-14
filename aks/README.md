# Azure Kubernetes Service (AKS) Module

Terraform module to create a production-ready AKS cluster with all required Azure infrastructure components.

## Design Principle

> **Terraform manages Azure infrastructure ONLY.**
> In-cluster resources (ingress, cert-manager, monitoring, etc.) are managed by Argo CD via GitOps.

## Architecture

```text
Terraform → AKS Cluster
             ├── System Node Pool (CoreDNS, kube-proxy)
             ├── User Node Pools (application workloads)
             ├── User Assigned Managed Identity
             ├── Log Analytics Workspace
             ├── Azure AD RBAC
             ├── Network Profile (Azure CNI)
             ├── Azure Policy
             ├── Key Vault CSI Driver
             ├── Workload Identity + OIDC
             ├── OMS Agent (Azure Monitor)
             ├── Image Cleaner
             ├── Auto-upgrade (patch channel)
             ├── Maintenance Window
             └── ACR Integration (optional)

Minimal Testing:

module "aks" {
  source = "../../"

  cluster_name        = "aks-test-app"
  resource_group_name = "rg-test-app"
  location            = "East US"
  kubernetes_version  = "1.31"
  sku_tier            = "Free"

  vnet_subnet_id = "/subscriptions/<sub-id>/resourceGroups/<rg>/providers/Microsoft.Network/virtualNetworks/<vnet>/subnets/<subnet>"

  system_node_pool = {
    name     = "system"
    vm_size  = "Standard_B2s"
    min_count = 1
    max_count = 2
    auto_scaling_enabled = true
    zones    = []
  }

  user_node_pools = {}

  environment = "test"
  project     = "my-app"
  owner_email = "user@example.com"
}


********************************************************************************

📋 AKS Cluster — Complete Component Summary
**What Terraform Created (Your Current Setup)**

┌─────────────────────────────────────────────────────────────┐
│  Azure Subscription: Seattle Azure Innovation Lab            │
│                                                             │
│  ┌── Module 1: resourcegroup ─────────────────────────────┐ │
│  │  rg-test-app                                           │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌── Module 2: vnet ──────────────────────────────────────┐ │
│  │  vnet-test-app (10.0.0.0/16)                           │ │
│  │  ├── snet-web  (10.0.1.0/24)                           │ │
│  │  ├── snet-app  (10.0.2.0/24) ← AKS nodes live here    │ │
│  │  └── snet-db   (10.0.3.0/24)                           │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌── Module 3: aks ───────────────────────────────────────┐ │
│  │  aks-test-app                                          │ │
│  │  ├── System Node Pool                                  │ │
│  │  ├── User Assigned Managed Identity                    │ │
│  │  ├── Log Analytics Workspace                           │ │
│  │  ├── Azure AD RBAC                                     │ │
│  │  ├── Network Profile (Azure CNI)                       │ │
│  │  ├── Azure Policy                                      │ │
│  │  ├── Key Vault CSI Driver                              │ │
│  │  ├── Workload Identity + OIDC                          │ │
│  │  ├── OMS Agent (Monitoring)                            │ │
│  │  ├── Image Cleaner                                     │ │
│  │  ├── Auto-upgrade (patch)                              │ │
│  │  └── Maintenance Window                                │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                             │
│  ┌── Module 4: aks_bootstrap (NEXT STEP) ─────────────────┐ │
│  │  Argo CD only → manages everything inside cluster      │ │
│  └────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
# Component-by-Component Breakdown

# AKS Cluster (Core):

Use Case: The core Kubernetes control plane managed by Azure. You don't manage master nodes — Azure does.

