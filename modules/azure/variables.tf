variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "ccf-blockchain-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "ccf-blockchain"
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "admin_username" {
  description = "Admin username for the virtual machine"
  type        = string
  default     = "azureuser"
}

variable "ccf_member_count" {
  description = "Number of CCF members"
  type        = number
  default     = 3
}

variable "app_uri" {
  description = "URI for the CCF application"
  type        = string
  default     = "https://github.com/microsoft/CCF/releases/download/ccf-4.0.0/sandbox_js.zip"
} 