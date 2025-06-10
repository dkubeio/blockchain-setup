variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "ssh_cidr" {
  description = "CIDR block for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

variable "resource_prefix" {
  description = "Prefix to be used for all resources"
  type        = string
  default     = "fabric"
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