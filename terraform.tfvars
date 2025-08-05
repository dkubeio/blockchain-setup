aws_region     = "us-east-1"
resource_prefix = "securelink"
vpc_cidr       = "10.0.0.0/16"
ssh_cidr       = "0.0.0.0/0"  # ⚠️ SECURITY WARNING: Restrict this to your specific IP address in production
network_name    = "securelink-network"
member_name     = "member1"
admin_username  = "admin"
instance_type   = "t3.medium"
chaincode_name  = "mycc"
github_ref = "v0.5.0-rc1"
ssh_key_name = "securelink-client"
tags = {
  Environment = "development"
  Project     = "DKube-SecureLink"
  ManagedBy   = "terraform"
}

# ⚠️ SECURITY WARNING:
# 1. Never commit this file with real credentials
# 2. Use strong, unique passwords
# 3. Restrict ssh_cidr to your specific IP
# 4. Consider using AWS Secrets Manager for sensitive values in production 