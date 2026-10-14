# AKS module: variables

# ─── Cluster Basics ───────────────────────────────────────────

variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Resource Group for AKS"
  type        = string
}

variable "location" {
  description = "Azure region for the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
  default     = "1.30"
}

variable "sku_tier" {
  description = "AKS SKU tier (Free or Standard). Use Standard for production SLA."
  type        = string
  default     = "Standard"
}

variable "private_cluster_enabled" {
  description = "Enable private cluster (API server not publicly accessible)"
  type        = bool
  default     = false
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = ""
}

# ─── Networking ───────────────────────────────────────────────

variable "vnet_subnet_id" {
  description = "Subnet ID for the AKS default node pool"
  type        = string
}

variable "service_cidr" {
  description = "Service CIDR for Kubernetes services"
  type        = string
  default     = "10.1.0.0/16"
}

variable "dns_service_ip" {
  description = "DNS service IP (must be within service_cidr)"
  type        = string
  default     = "10.1.0.10"
}

variable "network_plugin" {
  description = "Network plugin (azure or kubenet)"
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy (azure or calico)"
  type        = string
  default     = "azure"
}

variable "load_balancer_sku" {
  description = "Load balancer SKU (standard or basic)"
  type        = string
  default     = "standard"
}

# ─── System Node Pool ────────────────────────────────────────

variable "system_node_pool" {
  description = "Configuration for the system node pool"
  type = object({
    name                = optional(string, "system")
    vm_size             = optional(string, "Standard_D4s_v5")
    node_count          = optional(number, 3)
    min_count           = optional(number, 2)
    max_count           = optional(number, 5)
    os_disk_size_gb     = optional(number, 128)
    os_disk_type        = optional(string, "Managed")
    max_pods            = optional(number, 50)
    auto_scaling_enabled = optional(bool, true)
    zones               = optional(list(string), ["1", "2", "3"])
  })
  default = {}
}

# ─── User Node Pools ─────────────────────────────────────────

variable "user_node_pools" {
  description = "Map of additional user node pools"
  type = map(object({
    vm_size             = optional(string, "Standard_D4s_v5")
    node_count          = optional(number, 3)
    min_count           = optional(number, 2)
    max_count           = optional(number, 10)
    os_disk_size_gb     = optional(number, 128)
    os_disk_type        = optional(string, "Managed")
    max_pods            = optional(number, 50)
    auto_scaling_enabled = optional(bool, true)
    zones               = optional(list(string), ["1", "2", "3"])
    node_labels         = optional(map(string), {})
    node_taints         = optional(list(string), [])
  }))
  default = {}
}

# ─── Azure Container Registry ────────────────────────────────

variable "acr_id" {
  description = "Azure Container Registry ID to attach to AKS (for image pull)"
  type        = string
  default     = ""
}

# ─── Log Analytics ────────────────────────────────────────────

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for monitoring. If empty, a new one is created."
  type        = string
  default     = ""
}

variable "log_retention_in_days" {
  description = "Log retention in days for the Log Analytics Workspace"
  type        = number
  default     = 30
}

# ─── Features ─────────────────────────────────────────────────

variable "azure_policy_enabled" {
  description = "Enable Azure Policy for AKS"
  type        = bool
  default     = true
}

variable "key_vault_secrets_provider_enabled" {
  description = "Enable Azure Key Vault Secrets Provider CSI Driver"
  type        = bool
  default     = true
}

variable "workload_identity_enabled" {
  description = "Enable Workload Identity for pod-level Azure auth"
  type        = bool
  default     = true
}

variable "oidc_issuer_enabled" {
  description = "Enable OIDC issuer (required for Workload Identity)"
  type        = bool
  default     = true
}

variable "image_cleaner_enabled" {
  description = "Enable image cleaner to remove unused images"
  type        = bool
  default     = true
}

variable "image_cleaner_interval_hours" {
  description = "Interval in hours for image cleaner"
  type        = number
  default     = 48
}

# ─── Auto-upgrade ─────────────────────────────────────────────

variable "automatic_upgrade_channel" {
  description = "Auto-upgrade channel (none, patch, rapid, stable, node-image)"
  type        = string
  default     = "patch"
}

variable "node_os_upgrade_channel" {
  description = "Node OS upgrade channel (None, Unmanaged, SecurityPatch, NodeImage)"
  type        = string
  default     = "NodeImage"
}

# ─── Maintenance Window ──────────────────────────────────────

variable "maintenance_window_day" {
  description = "Day of week for maintenance window"
  type        = string
  default     = "Sunday"
}

variable "maintenance_window_hours" {
  description = "Allowed hours for maintenance window"
  type        = list(number)
  default     = [0, 1, 2, 3, 4, 5]
}

# ─── Tags & Metadata ─────────────────────────────────────────

variable "environment" {
  description = "Deployment environment (e.g., dev, test, prod)"
  type        = string
  default     = "prod"
}

variable "project" {
  description = "Project identifier"
  type        = string
  default     = ""
}

variable "owner_email" {
  description = "Owner email address"
  type        = string

  validation {
    condition     = can(regex("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$", var.owner_email))
    error_message = "owner_email must be a valid email address."
  }
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}

  validation {
    condition     = !contains(keys(var.tags), "CreatedBy") && !contains(keys(var.tags), "ManagedBy") && !contains(keys(var.tags), "Environment") && !contains(keys(var.tags), "Project") && !contains(keys(var.tags), "owner")
    error_message = "Tags cannot override reserved keys: CreatedBy, ManagedBy, Environment, Project, or owner."
  }
}