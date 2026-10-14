# VNet module: common tags

locals {
  common_tags = {
    CreatedBy   = "Terraform"
    ManagedBy   = "Terraform"
    Environment = var.environment
    Project     = var.project
    owner       = var.owner_email
  }
}