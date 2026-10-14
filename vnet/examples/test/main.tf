# Example: test VNet creation using the VNet module

module "vnet" {
  source = "../../"

  vnet_name           = "vnet-test-app"
  resource_group_name = "rg-test-app"
  location            = "East US"
  address_space       = ["10.0.0.0/16"]

  subnets = {
    "snet-web" = {
      address_prefixes = ["10.0.1.0/24"]
    }
    "snet-app" = {
      address_prefixes = ["10.0.2.0/24"]
    }
    "snet-db" = {
      address_prefixes = ["10.0.3.0/24"]
    }
  }

  dns_servers = []

  environment = "test"
  project     = "my-app"
  owner_email = "p.kumari@slalom.com"

  tags = {
    Department = "Platform_developer"
  }
}