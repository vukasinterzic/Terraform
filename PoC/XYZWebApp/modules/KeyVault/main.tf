# This module creates an Azure Key Vault and stores the username and password for the VMs in the Key Vault.

# Retrieve the current Azure client configuration to obtain tenant and object IDs.
data "azurerm_client_config" "current" {}

# Create an Azure Key Vault with deployment and template deployment enabled.
resource "azurerm_key_vault" "kv1" {
  name                            = "KV-${var.base_name}"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  sku_name                        = "standard"
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  enabled_for_deployment          = true
  enabled_for_template_deployment = true

  purge_protection_enabled = false

  tags = var.tags
    
  }

# Configure an access policy for the Key Vault, granting key and secret management permissions.
resource "azurerm_key_vault_access_policy" "kv1" {
  key_vault_id = azurerm_key_vault.kv1.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Get",
    "Create",
  ]

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Purge",
    "Recover",
  ]
}

# Generate a random password to be stored in the Key Vault.
resource "random_password" "xyz-random-password" {
  length           = var.password_length
  special          = false
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
}

# Store a predefined username as a secret in the Key Vault.
resource "azurerm_key_vault_secret" "xyz-user" {
  name         = "username"
  value        = var.admin_username
  key_vault_id = azurerm_key_vault.kv1.id

  depends_on = [azurerm_key_vault_access_policy.kv1]
}

# Store the generated random password as a secret in the Key Vault.
resource "azurerm_key_vault_secret" "xyz-password" {
  name         = "password"
  value        = random_password.xyz-random-password.result
  key_vault_id = azurerm_key_vault.kv1.id

  depends_on = [azurerm_key_vault_access_policy.kv1]
}