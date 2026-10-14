# ═══════════════════════════════════════════════════════════════
# AKS Bootstrap Module — MINIMAL TERRAFORM FOOTPRINT
# ═══════════════════════════════════════════════════════════════
#
# Terraform's ONLY responsibilities inside the cluster:
#   1. Create the argocd namespace
#   2. Install the Argo CD Helm chart
#   3. Deploy a single "App of Apps" manifest
#
# Everything else (ingress, cert-manager, prometheus, secrets,
# namespaces, RBAC, CRDs, etc.) is managed by Argo CD via GitOps.
#
# WHY: Argo CD handles drift detection continuously. Terraform
# is not designed for in-cluster resource management. Having both
# manage the same resources creates conflicts.
# ═══════════════════════════════════════════════════════════════

# ─── Data: Get AKS Credentials ───────────────────────────────

data "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  resource_group_name = var.resource_group_name
}

# ─── Configure Providers ─────────────────────────────────────

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.this.kube_config[0].host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.this.kube_config[0].client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.this.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
  }
}

provider "kubectl" {
  host                   = data.azurerm_kubernetes_cluster.this.kube_config[0].host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.this.kube_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.this.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
  load_config_file       = false
}

# ═══════════════════════════════════════════════════════════════
# STEP 1: Argo CD Namespace (only namespace Terraform creates)
# ═══════════════════════════════════════════════════════════════

resource "kubectl_manifest" "argocd_namespace" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: ${var.argocd_namespace}
      labels:
        app.kubernetes.io/managed-by: terraform
        purpose: gitops-controller
  YAML
}

# ═══════════════════════════════════════════════════════════════
# STEP 2: Install Argo CD Helm Chart
# ═══════════════════════════════════════════════════════════════

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version
  namespace  = var.argocd_namespace
  timeout    = 600
  wait       = true

  # ─── HA Mode ─────────────────────────────────────────────
  set {
    name  = "redis-ha.enabled"
    value = var.argocd_ha_enabled ? "true" : "false"
  }

  set {
    name  = "controller.replicas"
    value = var.argocd_ha_enabled ? "2" : "1"
  }

  set {
    name  = "server.replicas"
    value = var.argocd_ha_enabled ? "2" : "1"
  }

  set {
    name  = "repoServer.replicas"
    value = var.argocd_ha_enabled ? "2" : "1"
  }

  set {
    name  = "applicationSet.replicas"
    value = var.argocd_ha_enabled ? "2" : "1"
  }

  # ─── Server Configuration ───────────────────────────────
  set {
    name  = "server.service.type"
    value = var.argocd_server_service_type
  }

  # Allow Argo CD to manage itself (self-managed pattern)
  set {
    name  = "server.config.application\\.resourceTrackingMethod"
    value = "annotation"
  }

  # ─── Disable Argo CD managing its own CRDs via Helm ─────
  # Let Argo CD manage its own upgrades after initial install
  set {
    name  = "crds.install"
    value = "true"
  }

  set {
    name  = "crds.keep"
    value = "true"
  }

  depends_on = [kubectl_manifest.argocd_namespace]
}

# ═══════════════════════════════════════════════════════════════
# STEP 3: App of Apps — THE SINGLE ENTRY POINT FOR GITOPS
# ═══════════════════════════════════════════════════════════════
#
# This is the ONLY Argo CD Application Terraform creates.
# This "App of Apps" points to a Git repo that contains
# definitions for ALL other applications. Argo CD then
# manages everything from here.
#
# Git Repo Structure (managed by Argo CD, NOT Terraform):
#   gitops-repo/
#   ├── apps/
#   │   ├── ingress-nginx.yaml
#   │   ├── cert-manager.yaml
#   │   ├── prometheus-stack.yaml
#   │   ├── external-secrets.yaml
#   │   └── namespaces.yaml
#   ├── base/
#   │   ├── ingress-nginx/
#   │   ├── cert-manager/
#   │   ├── monitoring/
#   │   └── external-secrets/
#   └── overlays/
#       ├── dev/
#       ├── test/
#       └── prod/
# ═══════════════════════════════════════════════════════════════

resource "kubectl_manifest" "app_of_apps" {
  yaml_body = <<-YAML
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: app-of-apps
      namespace: ${var.argocd_namespace}
      labels:
        app.kubernetes.io/managed-by: terraform
        purpose: gitops-entrypoint
      finalizers:
        - resources-finalizer.argocd.argoproj.io
    spec:
      project: default
      source:
        repoURL: ${var.gitops_repo_url}
        targetRevision: ${var.gitops_repo_branch}
        path: ${var.gitops_repo_path}
      destination:
        server: ${var.gitops_target_cluster}
        namespace: ${var.argocd_namespace}
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
          allowEmpty: false
        syncOptions:
          - CreateNamespace=true
          - PrunePropagationPolicy=foreground
          - PruneLast=true
        retry:
          limit: 5
          backoff:
            duration: 5s
            factor: 2
            maxDuration: 3m
  YAML

  depends_on = [helm_release.argocd]
}