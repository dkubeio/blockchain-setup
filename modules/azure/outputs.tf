output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.ccf_rg.name
}

output "vm_public_ip" {
  description = "Public IP address of the virtual machine"
  value       = azurerm_public_ip.vm_pip.ip_address
}

output "vm_ssh_command" {
  description = "SSH command to connect to the virtual machine"
  value       = "ssh -i ${path.module}/id_rsa ${var.admin_username}@${azurerm_public_ip.vm_pip.ip_address}"
}

output "ssh_private_key_path" {
  description = "Path to the generated SSH private key"
  value       = local_file.ssh_private_key.filename
}

output "ssh_public_key_path" {
  description = "Path to the generated SSH public key"
  value       = local_file.ssh_public_key.filename
}

output "ccf_member0_private_key_path" {
  description = "Path to the CCF member0 private key"
  value       = local_file.member0_privk.filename
}

output "ccf_member0_certificate_path" {
  description = "Path to the CCF member0 certificate"
  value       = local_file.member0_cert.filename
}

output "ccf_id" {
  description = "CCF Application ID"
  value       = data.external.ccf_info.result.ccf_id
}

output "ccf_identity_url" {
  description = "CCF Identity URL"
  value       = data.external.ccf_info.result.identity_url
}

output "ccf_identity_service_uri" {
  description = "CCF Identity Service URI"
  value       = data.external.ccf_info.result.identity_service_uri
}

output "ccf_app_uri" {
  description = "CCF Application URI"
  value       = data.external.ccf_info.result.app_uri
}

output "ccf_ledger_uri" {
  description = "CCF Ledger URI"
  value       = data.external.ccf_info.result.ledger_uri
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = azurerm_linux_virtual_machine.ccf_vm.name
}

output "vm_id" {
  description = "ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.ccf_vm.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.ccf_vnet.name
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = azurerm_subnet.vm_subnet.name
}

output "private_key_path" {
  description = "Path to the private key file"
  value       = local_file.ssh_private_key.filename
} 