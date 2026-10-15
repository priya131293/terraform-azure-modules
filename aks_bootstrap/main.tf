# ═══════════════════════════════════════════════════════════════
# AKS Bootstrap Module — MINIMAL TERRAFORM FOOTPRINT
# ═══════════════════════════════════════════════════════════════

# ─── Data: Get AKS Credentials ───────────────────────────────

data "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  resource_group_name = var.resource_group_name
}

# ─── Configure Providers (using admin credentials) ───────────

provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.this.kube_admin_config[0].host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.this.kube_admin_config[0].client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.this.kube_admin_config[0].client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.this.kube_admin_config[0].cluster_ca_certificate)
  }
}

provider "kubectl" {
  host                   = data.azurerm_kubernetes_cluster.this.kube_admin_config[0].host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.this.kube_admin_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.this.kube_admin_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.this.kube_admin_config[0].cluster_ca_certificate)
  load_config_file       = false
}

# ═══════════════════════════════════════════════════════════════
# STEP 1: Install Argo CD Helm Chart (Non-HA for single node)
# ═══════════════════════════════════════════════════════════════
/*resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  namespace        = var.argocd_namespace
  create_namespace = true
  timeout          = 900
  wait             = true

  # ─── Completely Disable HA (single node cluster) ─────────
  set {
    name  = "redis-ha.enabled"
    value = "false"
  }

  set {
    name  = "redis.enabled"
    value = "true"
  }

  set {
    name  = "controller.replicas"
    value = "1"
  }

  set {
    name  = "server.replicas"
    value = "1"
  }

  set {
    name  = "repoServer.replicas"
    value = "1"
  }

  set {
    name  = "applicationSet.replicas"
    value = "1"
  }

  # ─── Reduce Resource Requests (for small nodes) ─────────
  set {
    name  = "controller.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "128Mi"
  }

  set {
    name  = "server.resources.requests.cpu"
    value = "50m"
  }

  set {
    name  = "server.resources.requests.memory"
    value = "64Mi"
  }

  set {
    name  = "repoServer.resources.requests.cpu"
    value = "50m"
  }

  set {
    name  = "repoServer.resources.requests.memory"
    value = "64Mi"
  }

  set {
    name  = "redis.resources.requests.cpu"
    value = "50m"
  }

  set {
    name  = "redis.resources.requests.memory"
    value = "64Mi"
  }

  # ─── Server Configuration ───────────────────────────────
  set {
    name  = "server.service.type"
    value = var.argocd_server_service_type
  }

  set {
    name  = "crds.install"
    value = "true"
  }

  set {
    name  = "crds.keep"
    value = "true"
  }
}
*/

# ═══════════════════════════════════════════════════════════════
# STEP 2: App of Apps — SINGLE ENTRY POINT FOR GITOPS
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

  #depends_on = [helm_release.argocd]
}