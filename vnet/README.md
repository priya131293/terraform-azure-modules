# Virtual Network

A Virtual Network (VNet) in Azure is a logically isolated network that securely connects Azure resources and extends on-premises networks. Key features include:

    Isolation: VNets provide isolation at the network level for segmenting resources and controlling traffic.

    Subnetting: Divide a VNet into subnets for resource organization and traffic control.

    Address Space: VNets have an address space defined using CIDR notation, determining the IP address range.

# Subnets, CIDR
Subnets

Subnets are subdivisions of a Virtual Network, allowing for better organization and traffic management.
CIDR (Classless Inter-Domain Routing)

CIDR notation represents IP addresses and their routing prefix, specifying the range of IP addresses for a network.
Routes and Route Tables
# Routes

Routes dictate how network traffic is directed, specifying the destination and next hop.
Route Tables

# Route Tables are collections of routes associated with subnets, enabling custom routing rules.
# Network Security Groups (NSGs)

NSGs are fundamental for Azure's network security, allowing filtering of inbound and outbound traffic. Key aspects include:

    Rules: NSGs define allowed or denied traffic based on source, destination, port, and protocol.

    Default Rules: NSGs have default rules for controlling traffic within the Virtual Network and between subnets.

    Association: NSGs can be associated with subnets or individual network interfaces.

# Application Security Groups (ASGs)

ASGs group Azure virtual machines based on application requirements, simplifying network security:

    Simplification: ASGs allow defining rules based on application roles instead of individual IP addresses.

    Dynamic Membership: ASGs support dynamic membership based on tags or other attributes.

    Rule Association: Security rules can be associated with ASGs for intuitive and scalable network security management.


# Azure Virtual Network Module

Terraform module to create and manage Azure Virtual Networks with subnets and standardized tagging.

## Architecture

```text
Terraform → Azure Virtual Network
             ├── VNet (address space)
             ├── Subnets (multiple, configurable)
             ├── DNS Servers (optional)
             └── Tags

 # # USAGE 
            
   module "vnet" {
  source = "../../"

  vnet_name           = "vnet-my-app"
  resource_group_name = "rg-my-app"
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

  environment = "prod"
  project     = "my-app"
  owner_email = "user@example.com"
}         

Requirements
Name	Version
terraform	>= 1.5
azurerm	~> 4.0
Inputs
Name	Description	Type	Default	Required
vnet_name	Name of the Virtual Network	string	—	yes
resource_group_name	Name of the Resource Group	string	—	yes
location	Azure region	string	—	yes
address_space	VNet address space	list(string)	["10.0.0.0/16"]	no
subnets	Map of subnets to create	map(object)	{}	no
dns_servers	Custom DNS servers	list(string)	[]	no
environment	Deployment environment	string	"prod"	no
project	Project identifier	string	""	no
owner_email	Owner email address	string	—	yes
tags	Additional tags	map(string)	{}	no
Outputs
Name	Description
vnet_id	The ID of the Virtual Network
vnet_name	The name of the Virtual Network
vnet_location	The location of the Virtual Network
vnet_address_space	The address space of the VNet
subnet_ids	Map of subnet names to their IDs
subnet_address_prefixes	Map of subnet names to their address prefixes
Examples
Test — VNet with 3 subnets (web, app, db)