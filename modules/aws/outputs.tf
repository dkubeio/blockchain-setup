output "network_id" {
  description = "ID of the Managed Blockchain network"
  value       = data.external.network_info.result.network_id
}

output "member_id" {
  description = "ID of the Managed Blockchain member"
  value       = data.external.network_info.result.member_id
}

output "client_public_ip" {
  description = "Public IP address of the client VM"
  value       = aws_eip.client_eip.public_ip
}

output "private_key_path" {
  description = "Path to the private key file"
  value       = local_file.private_key.filename
}

output "client_vm_url" {
  description = "URL to access the Blockchain client UI"
  value       = "http://${aws_eip.client_eip.public_ip}:3000"
}
