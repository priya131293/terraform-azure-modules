# AKS Bootstrap module: outputs

output "argocd_namespace" {
  description = "Namespace where Argo CD is installed"
  value       = var.argocd_namespace
}

output "argocd_server_url" {
  description = "How to access Argo CD UI"
  value       = var.argocd_server_service_type == "LoadBalancer" ? "Check: kubectl get svc argocd-server -n ${var.argocd_namespace}" : "Run: kubectl port-forward svc/argocd-server -n ${var.argocd_namespace} 8080:443"
}

output "argocd_initial_password_command" {
  description = "Command to get the initial Argo CD admin password"
  value       = "kubectl -n ${var.argocd_namespace} get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"
}

output "gitops_repo_url" {
  description = "Git repository URL that Argo CD is tracking"
  value       = var.gitops_repo_url
}

output "gitops_repo_branch" {
  description = "Git branch Argo CD is tracking"
  value       = var.gitops_repo_branch
}

output "gitops_repo_path" {
  description = "Path in Git repo for App of Apps"
  value       = var.gitops_repo_path
}

output "terraform_managed_resources" {
  description = "Resources Terraform manages inside the cluster (should be minimal)"
  value = [
    "Namespace: ${var.argocd_namespace}",
    "Helm Release: argo-cd",
    "Application: app-of-apps",
  ]
}