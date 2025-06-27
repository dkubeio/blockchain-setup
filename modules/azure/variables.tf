variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "vm-blockchain-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "vm-blockchain"
}

variable "vm_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_B2ms"
}

variable "admin_username" {
  description = "Admin username for the virtual machine"
  type        = string
  default     = "azureuser"
}

variable "openai_api_key" {
  description = "OpenAI API key to set in environment"
  type        = string
  sensitive   = true
} 