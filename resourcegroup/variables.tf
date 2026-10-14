# Resource Group module: variables

variable "name" {
  description = "Name of the Azure Resource Group to create"
  type        = string
}

variable "location" {
  description = "Azure region for the Resource Group"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, stage, prod)"
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
  description = "Additional tags to apply to the Resource Group"
  type        = map(string)
  default     = {}

  validation {
    condition     = !contains(keys(var.tags), "CreatedBy") && !contains(keys(var.tags), "ManagedBy") && !contains(keys(var.tags), "Environment") && !contains(keys(var.tags), "Project") && !contains(keys(var.tags), "owner")
    error_message = "Tags cannot override reserved keys: CreatedBy, ManagedBy, Environment, Project, or owner."
  }
}