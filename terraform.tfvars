aws_region     = "us-east-1"
resource_prefix = "docvault"
vpc_cidr       = "10.0.0.0/16"
ssh_cidr       = "0.0.0.0/0"  # ⚠️ SECURITY WARNING: Restrict this to your specific IP address in production
network_name    = "docvault-network"
member_name     = "member1"
admin_username  = "admin"
instance_type   = "t3.medium"
chaincode_name  = "mycc"
github_ref = "v1.5.0"
ssh_key_name = "docvault-client"
tags = {
  Environment = "development"
  Project     = "DKube-DocVault"
  ManagedBy   = "terraform"
}

# ⚠️ SECURITY WARNING:
# 1. Never commit this file with real credentials
# 2. Use strong, unique passwords
# 3. Restrict ssh_cidr to your specific IP
# 4. Consider using AWS Secrets Manager for sensitive values in production 