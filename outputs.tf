# AWS outputs
output "aws_network_id" {
  description = "AWS Managed Blockchain network ID"
  value       = var.cloud_provider == "aws" ? module.aws[0].network_id : null
}

output "aws_member_id" {
  description = "AWS Managed Blockchain member ID"
  value       = var.cloud_provider == "aws" ? module.aws[0].member_id : null
}

output "aws_client_public_ip" {
  description = "Public IP of the AWS client instance"
  value       = var.cloud_provider == "aws" ? module.aws[0].client_public_ip : null
}

output "aws_private_key_path" {
  description = "Path to the AWS private key file"
  value       = var.cloud_provider == "aws" ? module.aws[0].private_key_path : null
}

output "aws_client_vm_url" {
  description = "URL to access the AWS Blockchain client UI"
  value       = var.cloud_provider == "aws" ? module.aws[0].client_vm_url : null
}

# Azure outputs
output "azure_resource_group_name" {
  description = "Name of the Azure resource group"
  value       = var.cloud_provider == "azure" ? module.azure[0].resource_group_name : null
}

output "azure_vm_public_ip" {
  description = "Public IP of the Azure VM"
  value       = var.cloud_provider == "azure" ? module.azure[0].vm_public_ip : null
}

output "azure_vm_ssh_command" {
  description = "SSH command to connect to the Azure VM"
  value       = var.cloud_provider == "azure" ? module.azure[0].vm_ssh_command : null
}

output "azure_vm_name" {
  description = "Name of the Azure VM"
  value       = var.cloud_provider == "azure" ? module.azure[0].vm_name : null
}

output "azure_private_key_path" {
  description = "Path to the Azure private key file"
  value       = var.cloud_provider == "azure" ? module.azure[0].private_key_path : null
}

# Common outputs
output "selected_provider" {
  description = "The currently selected provider"
  value       = var.cloud_provider
}

output "admin_username" {
  description = "Admin username for the blockchain nodes"
  value       = var.admin_username
} 