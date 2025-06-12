output "vpc_id" {
  description = "ID of the VPC"
  value       = module.network.vpc_id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.network.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.network.public_subnet_ids
}

output "client_instance_id" {
  description = "ID of the client EC2 instance"
  value       = aws_instance.client.id
}

output "client_instance_private_ip" {
  description = "Private IP of the client EC2 instance"
  value       = aws_instance.client.private_ip
}

output "vpc_endpoint_id" {
  description = "ID of the Managed Blockchain VPC endpoint"
  value       = aws_vpc_endpoint.managedblockchain.id
}

output "network_id" {
  description = "ID of the Managed Blockchain network"
  value       = data.external.network_info.result.network_id
}

output "member_id" {
  description = "ID of the Managed Blockchain member"
  value       = data.external.network_info.result.member_id
}

output "client_ip" {
  description = "Public IP address of the client VM"
  value       = aws_eip.client_eip.public_ip
}

output "key_pair_name" {
  description = "Name of the created key pair"
  value       = aws_key_pair.blockchain_key.key_name
}

output "private_key_path" {
  description = "Path to the private key file"
  value       = local_file.private_key.filename
}

output "client_vm_url" {
  description = "URL to access the Blockchain client UI"
  value       = "http://${aws_eip.client_eip.public_ip}:3000"
}
