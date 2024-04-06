#This module creates a PostgreSQL Flexible Server in Azure with a private DNS zone and virtual network link

# Create a private DNS zone for the PostgreSQL Flexible Server to enable private name resolution within the virtual network.
resource "azurerm_private_dns_zone" "dns1" {
  name                = "${var.private_dns_zone_name_prefix}.postgres.database.azure.com"
  resource_group_name = var.resource_group_name

  tags = {
    Description = "Private DNS zone for PostgreSQL Flexible Server"
  }
}

# Link the private DNS zone to the specified virtual network, allowing resources within the VNet to resolve the PostgreSQL server's private DNS name.
resource "azurerm_private_dns_zone_virtual_network_link" "dns1" {
  name                  = "${var.private_dns_zone_name_prefix}-link"
  private_dns_zone_name = azurerm_private_dns_zone.dns1.name
  virtual_network_id    = var.vnet_id
  resource_group_name   = var.resource_group_name
}

# Retrieve the PostgreSQL admin username from Azure Key Vault for secure access.
data "azurerm_key_vault" "kvdb" {
  name                = var.keyvault_name
  resource_group_name = var.resource_group_name

  depends_on = [var.keyvault_name]
}

# Retrieve the PostgreSQL admin username from Azure Key Vault for secure access.
data "azurerm_key_vault_secret" "userdb" {
  name         = var.admin_username_secret_name
  key_vault_id = data.azurerm_key_vault.kvdb.id

  depends_on = [data.azurerm_key_vault.kvdb]
}

# Retrieve the PostgreSQL admin password stored as a secret in Azure Key Vault.
data "azurerm_key_vault_secret" "passworddb" {
  name         = var.admin_password_secret_name
  key_vault_id = data.azurerm_key_vault.kvdb.id

  depends_on = [data.azurerm_key_vault.kvdb]
}

# Provision the PostgreSQL Flexible Server with a private DNS zone for secure and scalable database services.
resource "azurerm_postgresql_flexible_server" "xyz1" {
  name                   = var.postgresql_server_name
  resource_group_name    = var.resource_group_name
  location               = var.location
  delegated_subnet_id    = var.subnet_id
  private_dns_zone_id    = azurerm_private_dns_zone.dns1.id
  version                = "16"
  sku_name               = var.postgresql_server_sku
  storage_mb             = var.postgresql_server_storage_mb
  administrator_login    = data.azurerm_key_vault_secret.userdb.value
  administrator_password = data.azurerm_key_vault_secret.passworddb.value

  tags = var.tags

  depends_on = [azurerm_private_dns_zone_virtual_network_link.dns1]
}