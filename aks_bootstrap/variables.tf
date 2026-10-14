# AKS Bootstrap module: variables
# MINIMAL — Terraform only installs Argo CD. Everything else is managed by Argo CD.

# ─── AKS Cluster Reference ───────────────────────────────────

variable "cluster_name" {
  description = "Name of the AKS cluster to bootstrap"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group of the AKS cluster"
  type        = string
}

# ─── Argo CD Configuration ───────────────────────────────────

variable "argocd_namespace" {
  description = "Namespace for Argo CD installation"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Argo CD Helm chart version"
  type        = string
  default     = "7.3.11"
}

variable "argocd_ha_enabled" {
  description = "Enable HA mode for Argo CD (recommended for production)"
  type        = bool
  default     = true
}

variable "argocd_server_service_type" {
  description = "Service type for Argo CD server (LoadBalancer or ClusterIP)"
  type        = string
  default     = "ClusterIP"
}

# ─── App of Apps (GitOps entry point) ─────────────────────────

variable "gitops_repo_url" {
  description = "Git repository URL containing all cluster manifests"
  type        = string
}

variable "gitops_repo_branch" {
  description = "Git branch for Argo CD to track"
  type        = string
  default     = "main"
}

variable "gitops_repo_path" {
  description = "Path in the Git repo to the App of Apps manifests"
  type        = string
  default     = "apps"
}

variable "gitops_target_cluster" {
  description = "Target cluster for Argo CD (use https://kubernetes.default.svc for in-cluster)"
  type        = string
  default     = "https://kubernetes.default.svc"
}

# ─── Tags & Metadata ─────────────────────────────────────────

variable "environment" {
  description = "Deployment environment"
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