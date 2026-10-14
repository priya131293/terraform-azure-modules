# AKS module: locals

locals {
  common_tags = {
    CreatedBy   = "Terraform"
    ManagedBy   = "Terraform"
    Environment = var.environment
    Project     = var.project
    owner       = var.owner_email
  }

  dns_prefix = var.dns_prefix != "" ? var.dns_prefix : var.cluster_name

  create_log_analytics = var.log_analytics_workspace_id == ""

  log_analytics_id = local.create_log_analytics ? azurerm_log_analytics_workspace.this[0].id : var.log_analytics_workspace_id
}