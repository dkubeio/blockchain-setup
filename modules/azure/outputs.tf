output "vm_public_ip" {
  description = "Public IP address of the VM"
  value       = azurerm_public_ip.vm_pip.ip_address
}

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.vm_rg.name
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm.name
}

output "vm_ssh_command" {
  description = "SSH command to connect to the virtual machine"
  value       = "ssh -i ${path.module}/id_rsa ${var.admin_username}@${azurerm_public_ip.vm_pip.ip_address}"
}

output "private_key_path" {
  description = "Path to the private key file"
  value       = local_file.ssh_private_key.filename
}

output "ccf_id" {
  description = "ID of the CCF instance"
  value       = data.external.ccf_info.result.ccf_id
}

output "ccf_identity_url" {
  description = "Identity service URI of the CCF instance"
  value       = data.external.ccf_info.result.identity_url
}

output "ccf_app_uri" {
  description = "Application URI of the CCF instance"
  value       = data.external.ccf_info.result.app_uri
}

output "ccf_ledger_uri" {
  description = "Ledger URI of the CCF instance"
  value       = data.external.ccf_info.result.ledger_uri
}

output "member0_private_key_path" {
  description = "Path to the member0 private key file"
  value       = "${path.module}/member0_privk.pem"
}

output "member0_certificate_path" {
  description = "Path to the member0 certificate file"
  value       = "${path.module}/member0_cert.pem"
} 