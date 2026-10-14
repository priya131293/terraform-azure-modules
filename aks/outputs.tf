# AKS module: outputs

# ─── Cluster Info ─────────────────────────────────────────────

output "cluster_id" {
  description = "The ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.id
}

output "cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.name
}

output "cluster_fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.fqdn
}

output "private_fqdn" {
  description = "The private FQDN of the AKS cluster (if private)"
  value       = azurerm_kubernetes_cluster.this.private_fqdn
}

output "kubernetes_version" {
  description = "The Kubernetes version of the cluster"
  value       = azurerm_kubernetes_cluster.this.kubernetes_version
}

# ─── Kubeconfig ───────────────────────────────────────────────

output "kube_config_raw" {
  description = "Raw kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "kube_config_host" {
  description = "Kubernetes API server host"
  value       = azurerm_kubernetes_cluster.this.kube_config[0].host
  sensitive   = true
}

output "kube_config_client_certificate" {
  description = "Client certificate for Kubernetes auth"
  value       = azurerm_kubernetes_cluster.this.kube_config[0].client_certificate
  sensitive   = true
}

output "kube_config_client_key" {
  description = "Client key for Kubernetes auth"
  value       = azurerm_kubernetes_cluster.this.kube_config[0].client_key
  sensitive   = true
}

output "kube_config_ca_certificate" {
  description = "Cluster CA certificate"
  value       = azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate
  sensitive   = true
}

# ─── Identity ─────────────────────────────────────────────────

output "kubelet_identity_object_id" {
  description = "Object ID of the kubelet managed identity"
  value       = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
}

output "cluster_identity_principal_id" {
  description = "Principal ID of the cluster managed identity"
  value       = azurerm_user_assigned_identity.aks.principal_id
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for Workload Identity"
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

# ─── Networking ───────────────────────────────────────────────

output "node_resource_group" {
  description = "The auto-generated node resource group name"
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}

# ─── Node Pools ───────────────────────────────────────────────

output "user_node_pool_ids" {
  description = "Map of user node pool names to their IDs"
  value       = { for k, v in azurerm_kubernetes_cluster_node_pool.user : k => v.id }
}

# ─── Log Analytics ────────────────────────────────────────────

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = local.log_analytics_id
}