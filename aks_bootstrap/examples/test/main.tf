module "aks_bootstrap" {
  source = "../../"

  cluster_name        = "aks-test-app"
  resource_group_name = "rg-test-app"

  argocd_namespace           = "argocd"
  argocd_chart_version       = "7.3.11"
  argocd_ha_enabled          = false
  argocd_server_service_type = "ClusterIP"

  gitops_repo_url    = "https://github.com/priya131293/gitops-demo.git"
  gitops_repo_branch = "main"
  gitops_repo_path   = "apps"

  environment = "test"
  project     = "my-app"
  owner_email = "p.kumari@slalom.com"
}