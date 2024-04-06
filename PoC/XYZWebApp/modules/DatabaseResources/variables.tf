variable "base_name" {
  type        = string
  description = "The name pre/post-fix used as part of Azure Resource names"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which all resources in this example should be created"
}

variable "location" {
  type        = string
  description = "The Azure Region in which all resources in this example should be created"
}

variable "tags" {
  type = map(string)
  description = "A map of tags to add to all resources"
}

variable "vnet_id" {
  type        = string
  description = "The ID of the virtual network"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet"
}

variable "private_dns_zone_name_prefix" {
  type        = string
  description = "The prefix of the private DNS zone name"
}

variable "postgresql_server_name" {
  type        = string
  description = "The name of the PostgreSQL server"
}

variable "postgresql_server_sku" {
  type        = string
  description = "The SKU of the PostgreSQL server"
}

variable "postgresql_server_storage_mb" {
  type        = number
  description = "The storage capacity of the PostgreSQL server"
}

variable "keyvault_name" {
  type        = string
  description = "The name of the key vault"
}

variable "admin_username_secret_name" {
  type        = string
  description = "The name of the secret in the key vault containing the admin username"
}

variable "admin_password_secret_name" {
  type        = string
  description = "The name of the secret in the key vault containing the admin password"
}