output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.blockchain_vpc.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.blockchain_vpc.cidr_block
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

output "private_subnet_cidrs" {
  description = "CIDR blocks of the private subnets"
  value       = aws_subnet.private[*].cidr_block
}

output "public_subnet_cidrs" {
  description = "CIDR blocks of the public subnets"
  value       = aws_subnet.public[*].cidr_block
}

output "vpc_endpoint_sg_id" {
  description = "ID of the VPC endpoint security group"
  value       = aws_security_group.vpc_endpoint.id
}

output "client_sg_id" {
  description = "ID of the client security group"
  value       = aws_security_group.client.id
}

output "blockchain_sg_id" {
  description = "ID of the blockchain security group"
  value       = aws_security_group.blockchain.id
} 