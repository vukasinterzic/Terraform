
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

variable "password_length" {
  type        = number
  description = "The length of the password to generate"
  default     = 16
}

variable "admin_username" {
  type        = string
  description = "The username of the local administrator account"
  default     = "adminuser"
}