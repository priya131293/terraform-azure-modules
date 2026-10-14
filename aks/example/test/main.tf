# Example: Production-ready AKS cluster using existing RG and VNet

module "aks" {
  source = "../../"

  # ─── Cluster Basics ──────────────────────────────────────
  cluster_name        = "aks-test-app"
  resource_group_name = "rg-test-app"
  location            = "East US"
  kubernetes_version  = "1.37"
  sku_tier            = "Free"

  # ─── Networking ──────────────────────────────────────────
  vnet_subnet_id = "/subscriptions/cad44ef1-313a-4da8-8d66-a58b6467472e/resourceGroups/rg-test-app/providers/Microsoft.Network/virtualNetworks/vnet-test-app/subnets/snet-app"
  service_cidr   = "10.1.0.0/16"
  dns_service_ip = "10.1.0.10"

  # ─── System Node Pool ───────────────────────────────────
  system_node_pool = {
    name                = "system"
    vm_size             = "Standard_B2s"
    node_count          = 1
    min_count           = 1
    max_count           = 2
    os_disk_size_gb     = 64
    auto_scaling_enabled = true
    zones               = []
  }

  # ─── User Node Pools ────────────────────────────────────
  /*user_node_pools = {
    "apps" = {
      vm_size             = "Standard_D4s_v5"
      min_count           = 2
      max_count           = 10
      os_disk_size_gb     = 128
      auto_scaling_enabled = true
      zones               = ["1", "2", "3"]
      node_labels = {
        "workload-type" = "application"
      }
      node_taints = []
    }
    "monitoring" = {
      vm_size             = "Standard_D2s_v5"
      min_count           = 1
      max_count           = 3
      os_disk_size_gb     = 64
      auto_scaling_enabled = true
      zones               = ["1", "2", "3"]
      node_labels = {
        "workload-type" = "monitoring"
      }
      node_taints = ["dedicated=monitoring:NoSchedule"]
    }
  }
*/
  # ─── Features ────────────────────────────────────────────
  private_cluster_enabled           = false
  azure_policy_enabled              = true
  key_vault_secrets_provider_enabled = true
  workload_identity_enabled         = true
  oidc_issuer_enabled               = true
  image_cleaner_enabled             = true

  # ─── Auto-upgrade ───────────────────────────────────────
  automatic_upgrade_channel = "patch"
  node_os_upgrade_channel   = "NodeImage"

  # ─── Maintenance Window ─────────────────────────────────
  maintenance_window_day   = "Sunday"
  maintenance_window_hours = [0, 1, 2, 3, 4, 5]

  # ─── Tags ───────────────────────────────────────────────
  environment = "test"
  project     = "my-app"
  owner_email = "p.kumari@slalom.com"

  tags = {
    Department = "Platform_developer"
  }
}