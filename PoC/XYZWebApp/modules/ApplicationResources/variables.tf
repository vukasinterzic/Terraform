
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

variable "environment" {
  type        = string
  description = "The environment in which resources in this project should be created"
}

variable "tags" {
  type = map(string)
  description = "A map of tags to add to all resources"
}

variable "publicip_name" {
  type        = string
  description = "The name of the public IP address"
}

variable "domain_name_label" {
  type        = string
  description = "The DNS label for the public IP address"
}

variable "vmss_name" {
  type        = string
  description = "The name of the virtual machine scale set"
}

variable "vmss_sku" {
  type        = string
  description = "The SKU of the virtual machine scale set"
}

variable "vmss_instances" {
  type        = number
  description = "The number of virtual machines in the scale set"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet in which to place the virtual machine scale set"
}

variable "storage_account_name_prefix" {
  type        = string
  description = "The prefix for the storage account name"
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

