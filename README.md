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
This project provisions secure, multi-tier blockchain infrastructure using Terraform for document ledgering and securing AI interactions. The infrastructure supports both AWS Managed Blockchain (Hyperledger Fabric) and Azure VM deployments.

## 📁 Project Structure

```
blockchain-setup/
├── README.md                    # Updated documentation
├── main.tf                      # Main Terraform configuration
├── variables.tf                 # Variable definitions
├── outputs.tf                   # Output definitions
├── terraform.tfvars             # Configuration (no secrets)
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
        └── terraform.tfvars     # Azure configuration (no secrets)
```

### Key Components:

- **Root Configuration**: Main Terraform files that orchestrate the deployment
- **AWS Module**: Complete AWS Managed Blockchain setup with networking
- **Azure Module**: Complete Azure VM setup with networking
- **Network Submodule**: Reusable networking components for AWS
- **Configuration Files**: Secure terraform.tfvars files (no secrets stored)
- **Documentation**: Comprehensive guides and examples for both cloud providers

## 🛠️ Prerequisites

### ⚠️ Important: Cloud Provider and Secrets Management
**You must explicitly select your cloud provider and provide secrets** during terraform apply. There is no default selection to prevent accidental deployments.

### 🔐 Security Best Practices
- **Secrets are NOT stored in terraform.tfvars files** to prevent accidental commits
- **Provider selection is passed via command line** to ensure explicit choice
- **Environment variables** are used for sensitive data (GitHub token, OpenAI API key)

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

### 🔒 Command-Line Variable Approach

This project uses a secure approach where sensitive data and provider selection are passed via command-line variables:

```bash
# Set environment variables for secrets
export DKUBE_GIT_TOKEN="your-dkube-git-token"
export OPENAI_API_KEY="your-openai-api-key"

# Apply with all required variables
terraform apply -auto-approve \
  -var="github_token=$DKUBE_GIT_TOKEN" \
  -var="openai_api_key=$OPENAI_API_KEY" \
  -var="cloud_provider=aws"
```

**Benefits:**
- ✅ No secrets in version control
- ✅ Explicit provider selection prevents accidents
- ✅ Environment variables for sensitive data
- ✅ Clear audit trail of what was deployed

## 🚀 Quick Start

```sh
# Clone the repository
git clone https://github.com/dkubeio/blockchain-setup.git
cd blockchain-setup/

# Copy and configure variables
cp terraform.tfvars terraform.tfvars
# Edit terraform.tfvars with your preferred configuration (no secrets needed)

# Set environment variables for secrets
export DKUBE_GIT_TOKEN="your-dkube-git-token"
export OPENAI_API_KEY="your-openai-api-key"

# Initialize Terraform
terraform init -upgrade

# Apply the configuration with secrets passed via command line
terraform apply -auto-approve -var="github_token=$DKUBE_GIT_TOKEN" -var="openai_api_key=$OPENAI_API_KEY" -var="cloud_provider=aws"
```

## 🏗️ Terraform Deployment Guide

### Prerequisites Check

Before deploying, ensure you have the required tools and credentials:

```bash
# Check Terraform version (must be >= 1.0)
terraform version

# Check AWS CLI (for AWS deployment)
aws --version

# Check Azure CLI (for Azure deployment)
az --version
```

### Step 1: Configuration Setup

1. **Copy the configuration file:**
   ```bash
   cp terraform.tfvars terraform.tfvars
   ```

2. **Edit the configuration file:**
   ```bash
   # Using your preferred editor
   nano terraform.tfvars
   # or
   vim terraform.tfvars
   # or
   code terraform.tfvars
   ```

3. **Set environment variables for secrets:**
   ```bash
   export DKUBE_GIT_TOKEN="your-dkube-git-token"
   export OPENAI_API_KEY="your-openai-api-key"
   ```

### Step 2: Terraform Initialization

```bash
# Initialize Terraform and download providers
terraform init -upgrade

# Verify the configuration
terraform validate
```

### Step 3: Deployment Commands

#### Option A: Interactive Deployment (Recommended)
```bash
# Plan the deployment (shows what will be created)
terraform plan -var="github_token=$DKUBE_GIT_TOKEN" -var="openai_api_key=$OPENAI_API_KEY" -var="cloud_provider=aws"

# Apply the deployment (interactive confirmation)
terraform apply -var="github_token=$DKUBE_GIT_TOKEN" -var="openai_api_key=$OPENAI_API_KEY" -var="cloud_provider=aws"
```

#### Option B: Non-Interactive Deployment
```bash
# Plan and apply in one command (auto-approve)
terraform apply -auto-approve -var="github_token=$DKUBE_GIT_TOKEN" -var="openai_api_key=$OPENAI_API_KEY" -var="cloud_provider=aws"
```

#### Option C: Plan to File and Apply
```bash
# Save the plan to a file
terraform plan -var="github_token=$DKUBE_GIT_TOKEN" -var="openai_api_key=$OPENAI_API_KEY" -var="cloud_provider=aws" -out=deployment.tfplan

# Apply the saved plan
terraform apply deployment.tfplan
```

### Step 4: Verification Commands

```bash
# Check the status of your deployment
terraform show

# List all created resources
terraform state list

# Get specific output values
terraform output

# Get a specific output
terraform output client_vm_url  # For AWS
terraform output azure_vm_public_ip  # For Azure
```

### Step 5: Monitoring Deployment

#### For AWS Deployment:
```bash
# Monitor AWS Managed Blockchain network creation
aws managedblockchain list-networks --region us-east-1

# Check EC2 instance status
aws ec2 describe-instances --filters "Name=tag:Name,Values=*blockchain*" --query 'Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]'
```

#### For Azure Deployment:
```bash
# Monitor VM status
az vm show -g blockchain-rg -n blockchain-vm --show-details --query powerState

# Check CCF status
az ccf show --name blockchain-ccf --resource-group blockchain-rg --query "properties.provisioningState"
```

### Example Deployment Commands

#### AWS Deployment Example:
```bash
# 1. Configure AWS credentials
aws configure

# 2. Set up terraform.tfvars for AWS
cat > terraform.tfvars << EOF
aws_region = "us-east-1"
vpc_cidr = "10.0.0.0/16"
ssh_cidr = "0.0.0.0/0"
resource_prefix = "blockchain"
network_name = "docvault-network"
member_name = "docvault-member"
admin_password = null
tags = {
  Environment = "development"
  Project = "blockchain-setup"
  Owner = "your-name"
}
EOF

# 3. Set environment variables for secrets
export DKUBE_GIT_TOKEN="your-dkube-git-token"
export OPENAI_API_KEY="your-openai-api-key"

# 4. Deploy
terraform init -upgrade
terraform plan -var="github_token=$DKUBE_GIT_TOKEN" -var="openai_api_key=$OPENAI_API_KEY" -var="cloud_provider=aws"
terraform apply -auto-approve -var="github_token=$DKUBE_GIT_TOKEN" -var="openai_api_key=$OPENAI_API_KEY" -var="cloud_provider=aws"
```

#### Azure Deployment Example:
```bash
# 1. Login to Azure
az login
az account set --subscription <your-subscription-id>

# 2. Set up terraform.tfvars for Azure
cat > terraform.tfvars << EOF
azure_resource_group_name = "blockchain-rg"
azure_location = "East US"
azure_prefix = "blockchain"
azure_vm_size = "Standard_D2s_v3"
admin_username = "admin"
EOF

# 3. Set environment variables for secrets
export DKUBE_GIT_TOKEN="your-dkube-git-token"
export OPENAI_API_KEY="your-openai-api-key"

# 4. Deploy
terraform init -upgrade
terraform plan -var="github_token=$DKUBE_GIT_TOKEN" -var="openai_api_key=$OPENAI_API_KEY" -var="cloud_provider=azure"
terraform apply -auto-approve -var="github_token=$DKUBE_GIT_TOKEN" -var="openai_api_key=$OPENAI_API_KEY" -var="cloud_provider=azure"
```

### Troubleshooting Deployment

#### Common Issues and Solutions:

1. **Provider Authentication Errors:**
   ```bash
   # For AWS
   aws sts get-caller-identity
   
   # For Azure
   az account show
   ```

2. **Terraform State Issues:**
   ```bash
   # Refresh state
   terraform refresh
   
   # Import existing resources (if needed)
   terraform import <resource_address> <resource_id>
   ```

3. **Resource Creation Failures:**
   ```bash
   # Check detailed logs
   TF_LOG=DEBUG terraform apply
   
   # Destroy and recreate specific resources
   terraform destroy -target=module.aws
   terraform apply
   ```

4. **Network Timeout Issues:**
   ```bash
   # Increase timeout for long-running operations
   export TF_VAR_aws_region="us-east-1"
   terraform apply -auto-approve
   ```

### Cleanup Commands

```bash
# Destroy all resources
terraform destroy -auto-approve

# Destroy specific module
terraform destroy -target=module.aws -auto-approve
terraform destroy -target=module.azure -auto-approve

# Force destroy (use with caution)
terraform destroy -auto-approve -refresh=false
```

## ☁️ Cloud Provider Selection

This project supports both AWS and Azure cloud providers. **You must explicitly choose your preferred platform** by passing the `cloud_provider` variable during terraform apply. There is no default selection to prevent accidental deployments.

### Required Configuration

**⚠️ IMPORTANT**: You must pass the `cloud_provider` variable during terraform apply commands.

```bash
# For AWS deployment
terraform apply -var="cloud_provider=aws" -var="github_token=$DKUBE_GIT_TOKEN" -var="openai_api_key=$OPENAI_API_KEY"

# For Azure deployment  
terraform apply -var="cloud_provider=azure" -var="github_token=$DKUBE_GIT_TOKEN" -var="openai_api_key=$OPENAI_API_KEY"
```

### Validation

The configuration validates that only one cloud provider is selected:
- Valid values: `"aws"` or `"azure"`
- Invalid values will result in a validation error
- Only resources for the selected provider will be created

### Example Configuration Files

#### AWS Configuration (`terraform.tfvars`):
```hcl
# AWS-specific variables
aws_region        = "us-east-1"
vpc_cidr          = "10.0.0.0/16"
ssh_cidr          = "0.0.0.0/0"
resource_prefix   = "blockchain"
network_name      = "docvault-network"
member_name       = "docvault-member"
admin_password    = null

# AWS tags
tags = {
  Environment = "development"
  Project     = "blockchain-setup"
  Owner       = "your-name"
}
```

#### Azure Configuration (`terraform.tfvars`):
```hcl
# Azure-specific variables
azure_resource_group_name = "blockchain-rg"
azure_location           = "East US"
azure_prefix             = "blockchain"
azure_vm_size            = "Standard_D2s_v3"
azure_ccf_member_count   = 3
admin_username           = "admin"
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
# AWS-specific variables
aws_region        = "us-east-1"
vpc_cidr          = "10.0.0.0/16"
ssh_cidr          = "0.0.0.0/0"  # Recommended: "your-ip/32" for security
resource_prefix   = "blockchain"
network_name      = "docvault-network"
member_name       = "docvault-member"
admin_password    = null  # Will be auto-generated if not provided

# AWS tags
tags = {
  Environment = "development"
  Project     = "blockchain-setup"
  Owner       = "your-name"
}
```

### AWS Deployment Commands
```sh
# Set environment variables for secrets
export DKUBE_GIT_TOKEN="your-dkube-git-token"
export OPENAI_API_KEY="your-openai-api-key"

# Initialize (if not already done)
terraform init -upgrade

# Plan AWS deployment
terraform plan -var="github_token=$DKUBE_GIT_TOKEN" -var="openai_api_key=$OPENAI_API_KEY" -var="cloud_provider=aws"

# Apply AWS deployment
terraform apply -auto-approve -var="github_token=$DKUBE_GIT_TOKEN" -var="openai_api_key=$OPENAI_API_KEY" -var="cloud_provider=aws"
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
# Azure-specific variables
azure_resource_group_name = "blockchain-rg"
azure_location           = "East US"
azure_prefix             = "blockchain"
azure_vm_size            = "Standard_D2s_v3"
azure_ccf_member_count   = 3
```

### Azure Deployment Commands
```sh
# Set environment variables for secrets
export DKUBE_GIT_TOKEN="your-dkube-git-token"
export OPENAI_API_KEY="your-openai-api-key"

# Initialize (if not already done)
terraform init -upgrade

# Plan Azure deployment
terraform plan -var="github_token=$DKUBE_GIT_TOKEN" -var="openai_api_key=$OPENAI_API_KEY" -var="cloud_provider=azure"

# Apply Azure deployment
terraform apply -auto-approve -var="github_token=$DKUBE_GIT_TOKEN" -var="openai_api_key=$OPENAI_API_KEY" -var="cloud_provider=azure"
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

3. **Access VM Resources**
   - SSH private key: `terraform output azure_private_key_path`
   - Resource group: `terraform output azure_resource_group_name`
   - VM name: `terraform output azure_vm_name`

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

### Azure Resource Creation Sequence (10-15 minutes total):

1. **🔷 Azure Infrastructure** (5-10 minutes):
   - Resource Group
   - Virtual Network and Subnet
   - Network Security Group
   - Public IP and Network Interface

2. **💻 Virtual Machine** (5-10 minutes):
   - Ubuntu 22.04 LTS VM
   - Pre-installed tools (Docker, Azure CLI, Node.js)
   - SSH key generation

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
terraform destroy -auto-approve -var="github_token=dummy_token" -var="openai_api_key=dummy_key" -var="cloud_provider=aws"
```

### Azure Cleanup
```bash
# Destroy Azure resources (automatically deletes generated files)
terraform destroy -auto-approve -var="github_token=dummy_token" -var="openai_api_key=dummy_key" -var="cloud_provider=azure"
```

⚠️ **Warning**: This will permanently delete all resources. Ensure you have backups if needed.

### Generated Files Cleanup
- **AWS**: No local files generated
- **Azure**: SSH keys (`id_rsa`, `id_rsa.pub`) are automatically deleted during `terraform destroy`

---

Built for enterprise Document Security solutions | Powered by AWS Managed Private Blockchain & Azure VM Infrastructure