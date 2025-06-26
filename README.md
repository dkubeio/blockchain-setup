# 🏗️ DKube DocVault Terraform Setup

[![Terraform Version](https://img.shields.io/badge/terraform-1.6+-blue.svg)](https://www.terraform.io/downloads.html)
[![AWS](https://img.shields.io/badge/AWS-Cloud-orange.svg)](https://aws.amazon.com)
[![Azure](https://img.shields.io/badge/Azure-Cloud-blue.svg)](https://azure.microsoft.com)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/dkubeio/blockchain-setup/graphs/commit-activity)

<div align="center">
<img src="images/dkube-docvault.svg" alt="Dkube DocVault Banner" width="600"/>
</div>

## 📋 Table of Contents
- [Overview](#-overview)
- [Project Structure](#-project-structure)
- [Prerequisites](#️-prerequisites)
- [Quick Start](#-quick-start)
- [Cloud Provider Selection](#-cloud-provider-selection)
- [AWS Deployment](#-aws-deployment)
- [Azure Deployment](#-azure-deployment)
- [Accessing the Application](#-accessing-the-application)
- [Resource Creation](#-resource-creation)
- [Security](#-security)
- [Troubleshooting](#-troubleshooting)
- [Cleanup](#-cleanup)

## 🎯 Overview
This project provisions secure, multi-tier blockchain infrastructure using Terraform for document ledgering and securing AI interactions. The infrastructure supports both AWS Managed Blockchain (Hyperledger Fabric) and Azure Managed CCF (Confidential Consortium Framework) deployments.

## 📁 Project Structure

```
blockchain-setup/
├── README.md                    # Updated documentation
├── main.tf                      # Main Terraform configuration
├── variables.tf                 # Variable definitions
├── outputs.tf                   # Output definitions
├── terraform.tfvars.example     # Example configuration
├── .gitignore                   # Git ignore rules
├── images/                      # Documentation images
└── modules/
    ├── aws/                     # AWS module
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── modules/
    │       └── network/         # Network submodule
    │           ├── main.tf
    │           ├── variables.tf
    │           └── outputs.tf
    └── azure/                   # Azure module
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        ├── cloud-init.tpl
        ├── README.md
        └── terraform.tfvars.example
```

### Key Components:

- **Root Configuration**: Main Terraform files that orchestrate the deployment
- **AWS Module**: Complete AWS Managed Blockchain setup with networking
- **Azure Module**: Complete Azure Managed CCF setup with VM provisioning
- **Network Submodule**: Reusable networking components for AWS
- **Documentation**: Comprehensive guides and examples for both cloud providers

## 🛠️ Prerequisites

### 🔧 Required Tools
1. **Terraform Installation**
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

2. **Git Installation**
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

#### For AWS Deployment:
1. 🔐 AWS Account with appropriate permissions
2. <img src="images/mini-logo.svg" alt="Dkube" width="20" height="20"> Dkube provided Git Access Token
3. 🤖 OpenAI API Key

#### For Azure Deployment:
1. 🔐 Azure Account with appropriate permissions
2. Azure CLI configured and authenticated

## 🚀 Quick Start

```sh
# Clone the repository
git clone https://github.com/dkubeio/blockchain-setup.git
cd blockchain-setup/

# Copy and configure variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your preferred cloud provider and credentials

# Initialize Terraform
terraform init -upgrade

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply -auto-approve
```

## ☁️ Cloud Provider Selection

This project supports both AWS and Azure cloud providers. Choose your preferred platform by setting the `cloud_provider` variable in `terraform.tfvars`:

```hcl
# For AWS deployment
cloud_provider = "aws"

# For Azure deployment  
cloud_provider = "azure"
```

## 🏗️ AWS Deployment

### Prerequisites
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

### AWS Configuration
Edit `terraform.tfvars` with your AWS-specific values:

```hcl
# Provider selection
cloud_provider = "aws"

# AWS-specific variables
aws_region        = "us-east-1"
vpc_cidr          = "10.0.0.0/16"
ssh_cidr          = "0.0.0.0/0"  # Recommended: "your-ip/32" for security
resource_prefix   = "blockchain"
network_name      = "docvault-network"
member_name       = "docvault-member"
admin_password    = null  # Will be auto-generated if not provided
github_token      = "your-dkube-git-token"
openai_api_key    = "your-openai-api-key"

# AWS tags
tags = {
  Environment = "development"
  Project     = "blockchain-setup"
  Owner       = "your-name"
}
```

### AWS Deployment Commands
```sh
# Initialize (if not already done)
terraform init -upgrade

# Plan AWS deployment
terraform plan

# Apply AWS deployment
terraform apply -auto-approve
```

## 🔷 Azure Deployment

### Prerequisites
1. **Azure CLI Installation**
   ```sh
   # For macOS
   brew install azure-cli
   
   # For Ubuntu/Debian
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
   
   # For Windows
   # Download from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-windows
   ```

2. **Azure CLI Authentication**
   ```sh
   az login
   az account set --subscription <your-subscription-id>
   ```

### Azure Configuration
Edit `terraform.tfvars` with your Azure-specific values:

```hcl
# Provider selection
cloud_provider = "azure"

# Azure-specific variables
azure_resource_group_name = "blockchain-rg"
azure_location           = "East US"
azure_prefix             = "blockchain"
azure_vm_size            = "Standard_D2s_v3"
azure_ccf_member_count   = 3
```

### Azure Deployment Commands
```sh
# Initialize (if not already done)
terraform init -upgrade

# Plan Azure deployment
terraform plan

# Apply Azure deployment
terraform apply -auto-approve
```

## 🌐 Accessing the Application

### AWS Deployment Access
After successful AWS deployment:

1. **Get the Client VM IP**
   - The UI address will be shown in the terraform output
   - Look for the output labeled `client_vm_url`

2. **Access the UI**
   - Open your web browser
   - Navigate to: `client_vm_url`

3. **First-time Setup**
   - Click on "Sign Up" to create your account
   - Fill in your details and create a secure password
   - After signup, you can log in with your credentials

### Azure Deployment Access
After successful Azure deployment:

1. **Get the VM's Public IP**
   ```bash
   terraform output azure_vm_public_ip
   ```

2. **SSH into the VM**
   ```bash
   # Get the complete SSH command
   terraform output azure_vm_ssh_command
   
   # Or manually SSH using the generated key
   ssh -i modules/azure/id_rsa azureuser@<vm-public-ip>
   ```

3. **Access CCF Endpoints**
   - CCF ID: `terraform output azure_ccf_id`
   - Identity URL: `terraform output azure_ccf_identity_url`
   - Identity Service URI: `terraform output azure_ccf_identity_service_uri`
   - Application URI: `terraform output azure_ccf_app_uri`
   - Ledger URI: `terraform output azure_ccf_ledger_uri`

4. **Access CCF Tools and Certificates**
   - SSH private key: `terraform output azure_private_key_path`
   - CCF member0 private key: `terraform output azure_ccf_member0_private_key_path`
   - CCF member0 certificate: `terraform output azure_ccf_member0_certificate_path`

⚠️ **Important**: Make sure to save your login credentials securely as they will be needed for future access.

## ⚡ Resource Creation

### AWS Resource Creation Sequence (75-90 minutes total):

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

3. **💻 Client EC2 Instance Setup** (15-20 minutes):
   - Create EC2 instance in public subnet
   - Install dependencies (Node.js, Docker, AWS CLI, Fabric CLI)
   - Clone repository and configure
   - Attach Elastic IP

4. **🔗 Blockchain Configuration** (10-15 minutes):
   - Admin enrollment on blockchain
   - Channel creation and joining
   - Chaincode deployment and instantiation

5. **🌐 Client UI Setup** (5-10 minutes):
   - Install UI dependencies
   - Configure environment
   - Start application server

### Azure Resource Creation Sequence (15-20 minutes total):

1. **🔷 Azure Infrastructure** (5-10 minutes):
   - Resource Group
   - Virtual Network and Subnet
   - Network Security Group
   - Public IP and Network Interface

2. **💻 Virtual Machine** (5-10 minutes):
   - Ubuntu 22.04 LTS VM
   - Pre-installed tools (Docker, Azure CLI, CCF, Node.js)
   - SSH key generation

3. **⛓️ Managed CCF** (5-10 minutes):
   - CCF instance creation via Azure CLI
   - Member certificate generation
   - Endpoint configuration and retrieval

## 🛡️ Security

### Network Security
- **AWS**: Blockchain nodes in private subnets, client in public subnet with controlled access
- **Azure**: VM in public subnet with NSG rules, CCF with managed security
- VPC endpoints for AWS services
- Security groups with least privilege

### Access Control
- SSH access restricted to specific IPs (recommended)
- HTTPS-only communication
- IAM roles with minimal permissions (AWS)
- Azure RBAC with least privilege (Azure)
- Secure credential management

### Best Practices
- No hardcoded credentials
- Regular security updates
- Audit logging enabled
- Resource tagging for tracking
- Auto-generated SSH keys and certificates

## 🔧 Troubleshooting

### Common Issues

1. **❌ Deployment Failures**
   - Check cloud provider credentials and permissions
   - Verify region supports required services
   - Ensure all required tools are installed
   - Verify required tokens and API keys

2. **⚠️ Terraform Apply Failures**
   - Check error messages for specific issues
   - Verify cloud provider credentials permissions
   - Check service quotas and limits
   - Verify repository access

3. **⏳ Network Creation Delays**
   - **AWS**: Default wait time is 40 minutes for blockchain network
   - **Azure**: CCF creation typically takes 5-10 minutes
   - Check service status in cloud console

### AWS-Specific Issues
```bash
# Check AWS Managed Blockchain status
aws managedblockchain list-networks --region <your-region>

# Verify VPC endpoints
aws ec2 describe-vpc-endpoints --region <your-region>
```

### Azure-Specific Issues
```bash
# Check VM status
az vm show -g <resource-group> -n <vm-name> --show-details --query powerState

# Verify VM connectivity
az vm show -d -g <resource-group> -n <vm-name> --query publicIps

# Check CCF status
az ccf show --name <ccf-name> --resource-group <resource-group> --query "properties.provisioningState"
```

### Debugging Tips
- Enable Terraform debug logging: `TF_LOG=DEBUG terraform plan`
- Check cloud provider logs (CloudWatch for AWS, Log Analytics for Azure)
- Verify network connectivity
- Review security group/NSG rules

## 🧹 Cleanup

To destroy all created resources:

### AWS Cleanup
```bash
# Destroy AWS resources
terraform destroy -auto-approve -var="github_token=dummy_token" -var="openai_api_key=dummy_key"
```

### Azure Cleanup
```bash
# Destroy Azure resources (automatically deletes generated files)
terraform destroy -auto-approve
```

⚠️ **Warning**: This will permanently delete all resources. Ensure you have backups if needed.

### Generated Files Cleanup
- **AWS**: No local files generated
- **Azure**: SSH keys (`id_rsa`, `id_rsa.pub`) and CCF certificates (`member0_privk.pem`, `member0_cert.pem`) are automatically deleted during `terraform destroy`

---

Built for enterprise Document Security solutions | Powered by AWS Managed Private Blockchain & Azure Managed CCF