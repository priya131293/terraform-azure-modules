# AKS module: main resources

# ─── Log Analytics Workspace (if not provided) ───────────────

resource "azurerm_log_analytics_workspace" "this" {
  count = local.create_log_analytics ? 1 : 0

  name                = "law-${var.cluster_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_in_days

  tags = merge(local.common_tags, var.tags)
}

# ─── User Assigned Managed Identity ──────────────────────────

resource "azurerm_user_assigned_identity" "aks" {
  name                = "id-${var.cluster_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = merge(local.common_tags, var.tags)
}

# ─── AKS Cluster ─────────────────────────────────────────────

resource "azurerm_kubernetes_cluster" "this" {
  name                      = var.cluster_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  dns_prefix                = local.dns_prefix
  kubernetes_version        = var.kubernetes_version
  sku_tier                  = var.sku_tier
  private_cluster_enabled   = var.private_cluster_enabled
  azure_policy_enabled      = var.azure_policy_enabled
  workload_identity_enabled = var.workload_identity_enabled
  oidc_issuer_enabled       = var.oidc_issuer_enabled
  image_cleaner_enabled     = var.image_cleaner_enabled
  image_cleaner_interval_hours = var.image_cleaner_interval_hours
  automatic_upgrade_channel = var.automatic_upgrade_channel
  node_os_upgrade_channel   = var.node_os_upgrade_channel

  # ─── Identity ────────────────────────────────────────────

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  # ─── System Node Pool ───────────────────────────────────

  default_node_pool {
    name                 = var.system_node_pool.name
    vm_size              = var.system_node_pool.vm_size
    node_count           = var.system_node_pool.auto_scaling_enabled ? null : var.system_node_pool.node_count
    min_count            = var.system_node_pool.auto_scaling_enabled ? var.system_node_pool.min_count : null
    max_count            = var.system_node_pool.auto_scaling_enabled ? var.system_node_pool.max_count : null
    os_disk_size_gb      = var.system_node_pool.os_disk_size_gb
    os_disk_type         = var.system_node_pool.os_disk_type
    max_pods             = var.system_node_pool.max_pods
    auto_scaling_enabled = var.system_node_pool.auto_scaling_enabled
    vnet_subnet_id       = var.vnet_subnet_id
    zones                = var.system_node_pool.zones

    node_labels = {
      "nodepool-type" = "system"
      "environment"   = var.environment
    }

    upgrade_settings {
      max_surge                     = "10%"
      drain_timeout_in_minutes      = 0
      node_soak_duration_in_minutes = 0
    }
  }

  # ─── Network Profile ────────────────────────────────────

  network_profile {
    network_plugin    = var.network_plugin
    network_policy    = var.network_policy
    service_cidr      = var.service_cidr
    dns_service_ip    = var.dns_service_ip
    load_balancer_sku = var.load_balancer_sku
  }

  # ─── Azure AD RBAC ──────────────────────────────────────

  azure_active_directory_role_based_access_control {
    azure_rbac_enabled = true
    tenant_id          = data.azurerm_client_config.current.tenant_id
  }

  # ─── Monitoring (OMS Agent) ─────────────────────────────

  oms_agent {
    log_analytics_workspace_id = local.log_analytics_id
  }

  # ─── Key Vault CSI Driver ──────────────────────────────

  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider_enabled ? [1] : []
    content {
      secret_rotation_enabled  = true
      secret_rotation_interval = "2m"
    }
  }

  # ─── Maintenance Window ─────────────────────────────────

  maintenance_window {
    allowed {
      day   = var.maintenance_window_day
      hours = var.maintenance_window_hours
    }
  }

  tags = merge(local.common_tags, var.tags)

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
    ]
  }
}

# ─── Data Source: Current Client Config ───────────────────────

data "azurerm_client_config" "current" {}

# ─── User Node Pools ─────────────────────────────────────────

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  for_each = var.user_node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = each.value.vm_size
  node_count            = each.value.auto_scaling_enabled ? null : each.value.node_count
  min_count             = each.value.auto_scaling_enabled ? each.value.min_count : null
  max_count             = each.value.auto_scaling_enabled ? each.value.max_count : null
  os_disk_size_gb       = each.value.os_disk_size_gb
  os_disk_type          = each.value.os_disk_type
  max_pods              = each.value.max_pods
  auto_scaling_enabled  = each.value.auto_scaling_enabled
  vnet_subnet_id        = var.vnet_subnet_id
  zones                 = each.value.zones
  mode                  = "User"

  node_labels = merge(each.value.node_labels, {
    "nodepool-type" = "user"
    "environment"   = var.environment
    "workload"      = each.key
  })

  node_taints = each.value.node_taints

  upgrade_settings {
    max_surge                     = "10%"
    drain_timeout_in_minutes      = 0
    node_soak_duration_in_minutes = 0
  }

  tags = merge(local.common_tags, var.tags)

  lifecycle {
    ignore_changes = [
      node_count,
    ]
  }
}

# ─── ACR Attachment ───────────────────────────────────────────

resource "azurerm_role_assignment" "acr_pull" {
  count = var.acr_id != "" ? 1 : 0

  principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = var.acr_id
  skip_service_principal_aad_check = true
}