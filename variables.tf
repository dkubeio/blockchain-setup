variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "resource_prefix" {
  description = "Prefix to be used for all resources"
  type        = string
  default     = "fabric"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ssh_cidr" {
  description = "CIDR block for SSH access"
  type        = string
  default     = "0.0.0.0/0"  # Should be restricted to your IP in production
}

variable "network_name" {
  description = "Name of the Hyperledger Fabric network"
  type        = string
  default     = "fabric-network"
}

variable "member_name" {
  description = "Name of the network member"
  type        = string
  default     = "member1"
}

variable "admin_username" {
  description = "Admin username for the network"
  type        = string
  default     = "dkube"
}


variable "peer_node_name" {
  description = "Name of the peer node"
  type        = string
  default     = "peer1"
}

variable "instance_type" {
  description = "EC2 instance type for the client"
  type        = string
  default     = "t3.medium"
}

variable "tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
  default     = {
    Environment = "development"
    Project     = "hyperledger-fabric"
    ManagedBy   = "terraform"
  }
}

variable "ssh_key_name" {
  description = "Name of the SSH key pair to use for the EC2 instance"
  type        = string
  default     = "fabric-client"
}

variable "github_repo" {
  description = "GitHub repository in format owner/repo"
  type        = string
  default     = "dkubeio/Blockchain"
}

variable "github_ref" {
  description = "GitHub reference to clone (can be branch name or tag name)"
  type        = string
  default     = "v1.0.0"
}

variable "chaincode_name" {
  description = "Name of the chaincode to be deployed"
  type        = string
  default     = "mydl5"
}

variable "admin_password" {
  description = "Admin password for the network. If not provided, a random password will be generated"
  type        = string
  sensitive   = true
  default     = null
}

variable "github_token" {
  description = "GitHub personal access token for repository access"
  type        = string
  sensitive   = true
}

variable "openai_api_key" {
  description = "OpenAI API key"
  type        = string
  sensitive   = true
}

