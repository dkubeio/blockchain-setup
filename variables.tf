# Provider selection
variable "cloud_provider" {
  description = "Cloud provider to use (aws or azure)"
  type        = string
  default     = "aws"
  validation {
    condition     = contains(["aws", "azure"], var.cloud_provider)
    error_message = "Cloud provider must be either 'aws' or 'azure'."
  }
}

# Common variables
variable "admin_username" {
  description = "Admin username for the blockchain nodes"
  type        = string
  default     = "admin"
}

# AWS-specific variables
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ssh_cidr" {
  description = "CIDR block for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "resource_prefix" {
  description = "Prefix for AWS resource names"
  type        = string
  default     = "blockchain"
}

variable "network_name" {
  description = "Name of the blockchain network"
  type        = string
  default     = "docvault-network"
}

variable "member_name" {
  description = "Name of the blockchain member"
  type        = string
  default     = "docvault-member"
}

variable "admin_password" {
  description = "Admin password for blockchain network"
  type        = string
  default     = null
  sensitive   = true
}

variable "github_token" {
  description = "GitHub token for repository access"
  type        = string
  default     = null
  sensitive   = true
}

variable "openai_api_key" {
  description = "OpenAI API key"
  type        = string
  default     = null
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to AWS resources"
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "blockchain-setup"
  }
}

# Azure-specific variables
variable "azure_resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "blockchain-rg"
}

variable "azure_location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "azure_prefix" {
  description = "Prefix for Azure resource names"
  type        = string
  default     = "blockchain"
}

variable "azure_vm_size" {
  description = "Size of the Azure VM"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "azure_ccf_member_count" {
  description = "Number of CCF members"
  type        = number
  default     = 3
} 