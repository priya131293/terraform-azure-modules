# Example: Minimal AKS Bootstrap — ONLY Argo CD
#
# Terraform installs:
#   1. argocd namespace
#   2. Argo CD Helm chart
#   3. App of Apps manifest (points to GitOps repo)
#
# Argo CD manages EVERYTHING else:
#   - ingress-nginx
#   - cert-manager
#   - prometheus + grafana
#   - external-secrets
#   - namespaces
#   - RBAC
#   - application manifests

module "aks_bootstrap" {
  source = "../../"

  # ─── AKS Cluster Reference ──────────────────────────────
  cluster_name        = "aks-test-app"
  resource_group_name = "rg-test-app"

  # ─── Argo CD Configuration ──────────────────────────────
  argocd_namespace          = "argocd"
  argocd_chart_version      = "7.3.11"
  argocd_ha_enabled         = true
  argocd_server_service_type = "ClusterIP"

  # ─── GitOps Repo (App of Apps) ──────────────────────────
  gitops_repo_url    = "https://github.com/priya131293/gitops-demo.git"
  gitops_repo_branch = "main"
  gitops_repo_path   = "apps"

  # ─── Tags ───────────────────────────────────────────────
  environment = "test"
  project     = "my-app"
  owner_email = "p.kumari@slalom.com"
}