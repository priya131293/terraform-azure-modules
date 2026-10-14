# Resource Group module: outputs

output "rg_id" {
  description = "The ID of the Resource Group"
  value       = azurerm_resource_group.this.id
}

output "rg_name" {
  description = "The name of the Resource Group"
  value       = azurerm_resource_group.this.name
}

output "rg_location" {
  description = "The location of the Resource Group"
  value       = azurerm_resource_group.this.location
}