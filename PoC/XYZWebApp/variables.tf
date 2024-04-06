
// This is the main variable file for Terraform deployment:

variable "base_name" {
  type        = string
  description = "The name pre/post-fix used as part of Azure Resource names"
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
  default = {
    Business-Owner = "XYZ Corp"
  }
  description = "A map of tags to add to all resources"
}

variable "vnet_address_space" {
  type        = list(string)
  default     = ["10.0.0.0/16"]
  description = "The address space that is used the virtual network"
}

variable "subnet_prefixes" {
  type        = list(string)
  description = "The address space that is used for subnets"
}

variable "subnet_names" {
  type        = list(string)
  description = "The names of the subnets"
}

variable "admin_username" {
  type        = string
  description = "The username for the admin account"
}