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