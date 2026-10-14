# AKS Bootstrap module: locals

locals {
  common_tags = {
    CreatedBy   = "Terraform"
    ManagedBy   = "Terraform"
    Environment = var.environment
    Project     = var.project
    owner       = var.owner_email
  }
}