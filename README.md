# 🏗️ Blockchain Terraform Project Setup

[![Terraform Version](https://img.shields.io/badge/terraform-1.6+-blue.svg)](https://www.terraform.io/downloads.html)
[![AWS](https://img.shields.io/badge/AWS-Cloud-orange.svg)](https://aws.amazon.com)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/yourusername/blockchain-setup/graphs/commit-activity)

## 📋 Table of Contents
- [Overview](#-overview)
- [Prerequisites](#️-prerequisites)
- [Quick Start](#-quick-start)
- [Detailed Setup](#-detailed-setup)
- [Resource Creation](#-resource-creation)
- [Security](#-security)
- [Troubleshooting](#-troubleshooting)
- [Cleanup](#-cleanup)

## Overview
This project provisions a secure, multi-tier AWS network and Managed Blockchain resources using Terraform fro document ledgering and securing AI interactions. 

## 🛠️ Prerequisites

### 🔧 Required Tools
1. **AWS CLI Installation**
   ```sh
   # For macOS
   brew install awscli
   
   # For Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install awscli
   
   # For Windows
   # Download and install from https://aws.amazon.com/cli/
   ```

2. **AWS CLI Configuration**
   ```sh
   aws configure
   # Enter your AWS Access Key ID
   # Enter your AWS Secret Access Key
   # Enter your preferred region (e.g., us-east-1)
   # Enter output format (json)
   ```

3. **Terraform Installation**
   ```sh
   # For macOS
   brew install terraform
   
   # For Ubuntu/Debian
   curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
   sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
   sudo apt-get update && sudo apt-get install terraform
   
   # For Windows
   # Download from https://www.terraform.io/downloads.html
   ```

4. **Git Installation**
   ```sh
   # For macOS
   brew install git
   
   # For Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install git
   
   # For Windows
   # Download from https://git-scm.com/download/win
   ```

### 🔑 Required Credentials
1. 🔐 AWS Account with appropriate permissions
2. 🐙 GitHub Personal Access Token (with repo access)
3. 🤖 OpenAI API Key

## 🚀 Quick Start

```sh
# Clone the repository
git clone https://github.com/dkubeio/blockchain-setup.git
cd Blockchain/

# Create terraform.tfvars file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
# Required values:
# - github_token: Your GitHub personal access token
# - openai_api_key: Your OpenAI API key
# Optional values (recommended):
# - admin_password: A secure password for the network admin (default: auto-generated)
# - ssh_cidr: Your IP address for SSH access (e.g., "123.45.67.89/32") (recommended for security)

# Initialize and apply
terraform init
terraform plan -out=tf.plan
terraform apply tf.plan
```

## 📝 Detailed Setup

1. **📥 Clone the Repository**
   ```sh
   git clone https://github.com/dkubeio/blockchain-setup.git
   cd Blockchain/
   ```

2. **📝 Create terraform.tfvars**
   ```sh
   cp terraform.tfvars.example terraform.tfvars
   ```

3. **⚙️ Configure Variables**
   Edit `terraform.tfvars` with your values. Here are all available variables:

   ### 🔒 Required Variables
   - `github_token`: Your GitHub personal access token
   - `openai_api_key`: Your OpenAI API key

   ### 🔧 Optional Variables (with defaults)
   - `admin_password`: A secure password for the network admin (default: auto-generated)
   - `ssh_cidr`: Your IP address for SSH access (e.g., "123.45.67.89/32") (recommended for security)
   - `aws_region`: AWS region to deploy resources (default: "us-east-1")
   - `resource_prefix`: Prefix for all resource names (default: "fabric")
   - `vpc_cidr`: CIDR block for the VPC (default: "10.0.0.0/16")
   - `network_name`: Name of the Fabric network (default: "fabric-network")
   - `member_name`: Name of the network member (default: "member1")
   - `admin_username`: Admin username for the network (default: "admin")
   - `peer_node_name`: Name of the peer node (default: "peer1")
   - `instance_type`: EC2 instance type for the client (default: "t3.medium")
   - `ssh_key_name`: Name of the SSH key pair (default: "blockchain")
   - `github_repo`: GitHub repository in format owner/repo (default: "dkubeio/Blockchain")
   - `github_ref`: GitHub reference to clone (can be branch name or tag name) (default: "v1.0.0")
   - `chaincode_name`: Name of the chaincode to be deployed (default: "mycc")

   ⚠️ **Security Note**: 
   - Never commit `terraform.tfvars` to version control
   - Use strong, unique passwords for all credentials
   - Restrict `ssh_cidr` to your specific IP address
   - Consider using AWS Secrets Manager for sensitive values in production

4. **⚡ Initialize Terraform**
   ```sh
   terraform init
   ```

5. **📋 Plan the Deployment**
   ```sh
   terraform plan -out=tf.plan
   ```

6. **🚀 Apply the Deployment**
   ```sh
   terraform apply tf.plan
   ```

## ⏱️ Resource Creation

The infrastructure is created in the following sequence:

1. **🌐 VPC and Network Infrastructure** (5-10 minutes):
   - VPC with public and private subnets
   - Internet Gateway
   - Route tables and associations
   - Security groups for VPC endpoint, client, and blockchain nodes

2. **⛓️ Blockchain Network** (40-45 minutes):
   - Create Hyperledger Fabric network (waits 40 minutes)
   - Create VPC endpoint for Managed Blockchain
   - Create member in the network (waits 10 minutes)
   - Create peer node (waits 10 minutes)

3. **💻 Client Infrastructure** (5-10 minutes):
   - Create EC2 instance in public subnet
   - Install Git
   - Clone repository using GitHub token
   - Configure with user data script
   - Attach Elastic IP

Total deployment time: Approximately 60-65 minutes

## 🔒 Security

### Network Security
- Blockchain nodes in private subnets
- Client in public subnet with controlled access
- VPC endpoints for AWS services
- Security groups with least privilege

### Access Control
- SSH access restricted to specific IPs
- HTTPS-only communication
- IAM roles with minimal permissions
- Secure credential management

### Best Practices
- No hardcoded credentials
- Regular security updates
- Audit logging enabled
- Resource tagging for tracking

## 🔍 Troubleshooting

### Common Issues

1. **❌ Deployment Failures**
   - Check AWS CLI credentials and permissions
   - Verify AWS region supports Managed Blockchain
   - Ensure all required tools are installed
   - Verify GitHub token and OpenAI API key

2. **⚠️ Terraform Apply Failures**
   - Check error messages for specific issues
   - Verify AWS credentials permissions
   - Check AWS Managed Blockchain status
   - Verify GitHub repository access

3. **⏳ Network Creation Delays**
   - Default wait time is 40 minutes
   - Check network status:
     ```bash
     aws managedblockchain list-networks --region <your-region>
     ```

### Debugging Tips
- Enable Terraform debug logging: `TF_LOG=DEBUG terraform plan`
- Check AWS CloudWatch logs
- Verify network connectivity
- Review security group rules

## 🧹 Cleanup

To destroy all created resources:
```bash
terraform destroy
```

⚠️ **Warning**: This will permanently delete all resources. Ensure you have backups if needed.

---

Built for enterprise Document Security solutions | Powered by AWS Managed Private Blockchain