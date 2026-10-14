# Azure Resource Group Module

A Resource Group in Azure is a logical container for resources that share the same lifecycle, permissions, and policies. It helps you organize and manage related Azure resources efficiently. Resources within a group can be deployed, updated, and deleted together as a single management unit.
Terraform module to create and manage Azure Resource Groups with standardized tagging.

# Key Points about Resource Groups:

    Lifecycle Management: Resources within a group can be managed collectively, making it easy to handle deployments, updates, and deletions.

    Resource Organization: Grouping resources based on projects, environments, or applications helps keep your Azure environment well-organized.

    Role-Based Access Control (RBAC): Permissions and access control are applied at the resource group level, allowing you to manage who can access and modify resources within a group.

    Azure Resource Manager (ARM) Overview

Azure Resource Manager (ARM) is the deployment and management service for Azure. It provides a consistent management layer that enables you to deploy resources with declarative templates. ARM templates describe the resources you need and their configurations, allowing you to deploy and update resources in a predictable manner.
Key Features of Azure Resource Manager:

    Template-Based Deployment: ARM uses JSON templates to define the infrastructure and configuration of your Azure resources. This enables repeatable and consistent deployments.

    Dependency Management: ARM automatically handles dependencies between resources, ensuring they are deployed in the correct order.

    Rollback and Roll-forward: In case of deployment failures, ARM can automatically roll back changes to maintain the desired state, or roll forward to the last known good state.

    Tagging and Categorization: You can use tags to label and categorize resources, making it easier to manage and organize your Azure environment.

Note: Understanding Azure resources, resource groups, and Azure Resource Manager is fundamental to effectively utilize and manage your resources in the Azure cloud.


## Architecture

```text
Terraform → Azure Resource Group
             ├── Name
             ├── Location
             └── Tags (CreatedBy, ManagedBy, Environment, Project, owner + custom)


USAGE:

module "resourcegroup" {
  source = "../../"

  name        = "rg-my-app"
  location    = "East US"
  environment = "prod"
  project     = "my-app"
  owner_email = "user@example.com"

  tags = {
    Department = "Engineering"
  }
}

Requirements
Name	Version
terraform	>= 1.5
azurerm	~> 4.0
Inputs
Name	Description	Type	Default	Required
name	Name of the Azure Resource Group	string	—	yes
location	Azure region for the Resource Group	string	—	yes
environment	Deployment environment (dev, test, prod)	string	"prod"	no
project	Project identifier for tagging	string	""	no
owner_email	Owner email address for tagging	string	—	yes
tags	Additional tags (cannot override reserved keys)	map(string)	{}	no
Outputs
Name	Description
rg_id	The ID of the Resource Group
rg_name	The name of the Resource Group
rg_location	The location of the Resource Group
Reserved Tags
The following tags are automatically applied and cannot be overridden:

Tag	Value
CreatedBy	Terraform
ManagedBy	Terraform
Environment	var.environment
Project	var.project
owner	var.owner_email
Examples
Test — Basic resource group creation

  
