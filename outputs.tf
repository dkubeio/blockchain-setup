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

output "fabric_network_id" {
  description = "ID of the Fabric network"
  value       = data.external.network_info.result.network_id
}

output "fabric_member_id" {
  description = "ID of the Fabric network member"
  value       = data.external.network_info.result.member_id
}

output "client_public_ip" {
  description = "The public IP address of the client instance"
  value       = aws_eip.client_eip.public_ip
}
