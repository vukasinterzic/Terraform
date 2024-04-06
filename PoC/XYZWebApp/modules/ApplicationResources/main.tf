#This is the module to create VMSS and Load Balancer

# Create a static public IP address for the load balancer. This enables external access to the VMSS through the load balancer.
resource "azurerm_public_ip" "pip1" {
  name                = var.publicip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.domain_name_label
  tags = {
    Description = "Public IP for ${var.base_name} VMSS"
  }
}

# Create a standard SKU load balancer. This distributes incoming traffic across VMSS instances.
resource "azurerm_lb" "lb1" {
  name                = "LB-${var.base_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "FrontendIPConfiguration"
    public_ip_address_id = azurerm_public_ip.pip1.id
  }

  tags = {
    Description = "Load Balancer for ${var.base_name} VMSS"
  }
}

# Define a backend address pool for the load balancer. VMSS instances will be associated with this pool.
resource "azurerm_lb_backend_address_pool" "backend1" {
  name            = "backend-${lower(var.base_name)}"
  loadbalancer_id = azurerm_lb.lb1.id
}

# Setup a health probe on the load balancer. This ensures traffic is only routed to healthy instances.
resource "azurerm_lb_probe" "xyz1" {
  name            = "lbprobe-${lower(var.base_name)}"
  loadbalancer_id = azurerm_lb.lb1.id
  port            = 80
}

# Configure a load balancing rule for HTTP traffic, associating it with the health probe and backend address pool.
resource "azurerm_lb_rule" "xyz1" {
  name                           = "http"
  loadbalancer_id                = azurerm_lb.lb1.id
  frontend_ip_configuration_name = "FrontendIPConfiguration"
  probe_id                       = azurerm_lb_probe.xyz1.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.backend1.id]
}

# Retrieve the Key Vault instance to access stored secrets (admin username and password for VMSS).
data "azurerm_key_vault" "kvapp" {
  name                = var.keyvault_name
  resource_group_name = var.resource_group_name

  depends_on = [var.keyvault_name]
}

# Access the secret containing the VMSS admin username.
data "azurerm_key_vault_secret" "user" {
  name         = var.admin_username_secret_name
  key_vault_id = data.azurerm_key_vault.kvapp.id

  depends_on = [data.azurerm_key_vault.kvapp]
}

# Access the secret containing the VMSS admin password.
data "azurerm_key_vault_secret" "password" {
  name         = var.admin_password_secret_name
  key_vault_id = data.azurerm_key_vault.kvapp.id

  depends_on = [data.azurerm_key_vault.kvapp]
}

# Deploy a Linux Virtual Machine Scale Set (VMSS) with instances configured to use the backend address pool and health probe.
resource "azurerm_linux_virtual_machine_scale_set" "linuxvmss1" {
  name                = var.vmss_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.vmss_sku
  instances           = var.vmss_instances

  health_probe_id = azurerm_lb_probe.xyz1.id
  #custom_data     = filebase64("web.conf")

  admin_username = data.azurerm_key_vault_secret.user.value
  admin_password = data.azurerm_key_vault_secret.password.value

  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  network_interface {
    name    = "vNIC-${var.base_name}"
    primary = true

    ip_configuration {
      name                                   = "IPAddressConfiguration"
      primary                                = true
      subnet_id                              = var.subnet_id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.backend1.id]
    }
  }

  tags = var.tags

}

# Generate a random string to ensure the storage account name's uniqueness.
resource "random_string" "storage_account_name" {
  length  = 5
  special = false
  upper   = false
  lower   = true
  numeric  = true
}

# Provision an Azure Storage Account, which could be used for VMSS instance diagnostics or other storage needs.
resource "azurerm_storage_account" "storage_account" {
  name                     = "${var.storage_account_name_prefix}${random_string.storage_account_name.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    Description = "Storage Account for ${var.base_name} VMSS."
  }
}