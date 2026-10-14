# Resource Group module: creation

resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location

  tags = merge(local.common_tags, var.tags)
}