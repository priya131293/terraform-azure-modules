# VNet module: variables

variable "vnet_name" {
  description = "Name of the Azure Virtual Network"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group where VNet will be created"
  type        = string
}

variable "location" {
  description = "Azure region for the VNet"
  type        = string
}

variable "address_space" {
  description = "Address space for the VNet (e.g., [\"10.0.0.0/16\"])"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Map of subnets to create inside the VNet"
  type = map(object({
    address_prefixes = list(string)
  }))
  default = {}
}

variable "dns_servers" {
  description = "Custom DNS servers for the VNet (empty = Azure default DNS)"
  type        = list(string)
  default     = []
}

variable "environment" {
  description = "Deployment environment (e.g., dev, test, prod)"
  type        = string
  default     = "prod"
}

variable "project" {
  description = "Project identifier (for tagging/organization)"
  type        = string
  default     = ""
}

variable "owner_email" {
  description = "Owner email address to tag resources with"
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", var.owner_email))
    error_message = "owner_email must be a valid email address (e.g., user@domain.com)."
  }
}

variable "tags" {
  description = "Additional tags to apply to VNet resources"
  type        = map(string)
  default     = {}

  validation {
    condition     = !contains(keys(var.tags), "CreatedBy") && !contains(keys(var.tags), "ManagedBy") && !contains(keys(var.tags), "Environment") && !contains(keys(var.tags), "Project") && !contains(keys(var.tags), "owner")
    error_message = "Tags cannot override reserved keys: CreatedBy, ManagedBy, Environment, Project, or owner."
  }
}