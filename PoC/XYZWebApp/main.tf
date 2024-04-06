############################################
## XYZ Corp Online Sales Web Application ##
############################################

# Define the required Terraform version and the AzureRM provider version.
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.89.0"
    }
  }
}


# Configure the AzureRM provider with default features and opt to skip provider registration.
provider "azurerm" {
  features {}
  skip_provider_registration = true
}


// Define Azure Resources

# Create a resource group with a dynamic name based on environment and base name variables.
resource "azurerm_resource_group" "rg1" {
  name     = "RG-${var.environment}-${var.base_name}"
  location = var.location
  tags = merge(var.tags, {
    Description = "Resource Group for XYZ App"
  })
}

// Initiate modules

# Initialize the Virtual Network (VNet) module from the Terraform Registry to create a VNet and subnets.
module "vnet" {
  source              = "Azure/vnet/azurerm"
  version             = "4.1.0"
  resource_group_name = azurerm_resource_group.rg1.name
  use_for_each        = true
  vnet_location       = azurerm_resource_group.rg1.location
  vnet_name           = "VNET-${var.environment}-${var.base_name}"
  address_space       = var.vnet_address_space
  subnet_names        = var.subnet_names
  subnet_prefixes     = ["10.0.1.0/24", "10.0.2.0/24"]
  subnet_service_endpoints = {
    subnet2-db = ["Microsoft.Storage"]
  }
  subnet_delegation = {
    subnet2-db = {
      "Microsoft.DBforPostgreSQL/flexibleServers" = {
        service_name = "Microsoft.DBforPostgreSQL/flexibleServers"
        service_actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action",
        ]
      }
    }
  }

  tags = merge(var.tags, {
    Description = "Virtual Network for XYZ App"
  })
}


# Configure the KeyVault module to create an Azure Key Vault with access policies and stored secrets.
module "KeyVault" {
  source              = "./modules/KeyVault"
  base_name           = var.base_name
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  environment         = var.environment
  admin_username      = var.admin_username
  password_length     = 20
  tags = merge(var.tags, {
    Description = "Key Vault for ${var.base_name}."
  })
}

# Deploy application resources including VMSS and Load Balancer using the ApplicationResources module.
module "ApplicationResources" {
  source                     = "./modules/ApplicationResources"
  base_name                  = var.base_name
  resource_group_name        = azurerm_resource_group.rg1.name
  location                   = azurerm_resource_group.rg1.location
  environment                = var.environment
  keyvault_name              = module.KeyVault.kv_name_out
  admin_username_secret_name = module.KeyVault.secret_user_out
  admin_password_secret_name = module.KeyVault.secret_password_out

  publicip_name     = "PIP-${var.base_name}-LB"
  domain_name_label = "${lower(var.base_name)}onlinesales"

  vmss_name      = "VMSS-${var.environment}-${var.base_name}"
  vmss_sku       = "Standard_DS1_v2"
  vmss_instances = 2
  subnet_id   = lookup(module.vnet.vnet_subnets_name_id, var.subnet_names[0])

  storage_account_name_prefix = "sa${lower(var.base_name)}"

  tags = merge(var.tags, {
    Description = "Linux VMSS for ${var.base_name}."
  })
}


# Leverage the DatabaseResources module to provision a PostgreSQL Flexible Server with private connectivity.
module "DatabaseResources" {
  source                       = "./modules/DatabaseResources"
  base_name                    = var.base_name
  resource_group_name          = azurerm_resource_group.rg1.name
  location                     = azurerm_resource_group.rg1.location
  private_dns_zone_name_prefix = "${lower(var.base_name)}onlinesales"
  vnet_id                      = module.vnet.vnet_id
  subnet_id                    = lookup(module.vnet.vnet_subnets_name_id, var.subnet_names[1])
  postgresql_server_name       = "psql-${lower(var.environment)}-${lower(var.base_name)}"
  postgresql_server_sku        = "GP_Standard_D4s_v3"
  postgresql_server_storage_mb = 32768

  keyvault_name              = module.KeyVault.kv_name_out
  admin_username_secret_name = module.KeyVault.secret_user_out
  admin_password_secret_name = module.KeyVault.secret_password_out

  tags = merge(var.tags, {
    Description = "PostgreSQL DB for ${var.base_name}."
  })
}

