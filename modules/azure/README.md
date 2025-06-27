# Azure VM Terraform Configuration

This Terraform configuration deploys a simple Azure virtual machine with Docker, Azure CLI, and OpenAI API key configuration. The configuration automatically generates SSH keys for secure access.

## Prerequisites

1. **Azure CLI**: Install and authenticate with Azure
   ```bash
   az login
   az account set --subscription <your-subscription-id>
   ```

2. **Terraform**: Install Terraform (version >= 1.0)
   ```bash
   # macOS
   brew install terraform
   
   # Ubuntu/Debian
   sudo apt-get install terraform
   ```

3. **OpenAI API Key**: You'll need a valid OpenAI API key for the environment variable

## Deployment

1. **Clone and navigate to the terraform directory**
   ```bash
   cd terraform
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Review and customize variables (required)**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your preferred values
   # Make sure to set your OpenAI API key
   ```

4. **Plan the deployment**
   ```bash
   terraform plan
   ```

5. **Apply the configuration**
   ```bash
   terraform apply
   ```

6. **Confirm deployment**
   Type `yes` when prompted to confirm the deployment.

## Resources Created

- **Resource Group**: Contains all resources
- **Virtual Network**: Network infrastructure for the VM
- **Subnet**: Subnet for the VM
- **Network Security Group**: Firewall rules for SSH (22), Port 3000, Port 8000, and HTTPS (443)
- **Public IP**: Public IP address for the VM
- **Network Interface**: Network interface for the VM
- **Virtual Machine**: Ubuntu 22.04 LTS Standard B2ms VM with Docker, Azure CLI, and tools installed
- **System Assigned Identity**: VM identity with Owner permissions on the resource group
- **SSH Keys**: Automatically generated RSA key pair (4096 bits)

## Generated Files

After deployment, the following files will be created in the terraform directory:

- `id_rsa` - SSH private key (permissions: 600)
- `id_rsa.pub` - SSH public key (permissions: 644)

**Note**: These files will be automatically deleted when you run `terraform destroy`.

## VM Configuration

The VM is pre-configured with:
- Ubuntu 22.04 LTS
- Standard B2ms VM size (2 vCPUs, 8 GB RAM)
- Docker and Docker Compose (latest version)
- Azure CLI
- Node.js and npm
- Build tools
- System assigned identity with Owner permissions
- OpenAI API key set as environment variable

## Network Security

The following ports are open in the Network Security Group:
- **Port 22**: SSH access
- **Port 3000**: Application port
- **Port 8000**: Application port  
- **Port 443**: HTTPS access

## Accessing the VM via SSH

### Method 1: Using Terraform Outputs (Recommended)

After deployment, Terraform will display the VM's public IP address and complete SSH command:

```bash
# Get the VM's public IP
terraform output vm_public_ip

# Get the complete SSH command with the correct key
terraform output ssh_connection_command
```

### Method 2: Manual SSH Connection

1. **Get the VM's public IP address**:
   ```bash
   terraform output vm_public_ip
   ```

2. **SSH into the VM** using the generated private key:
   ```bash
   ssh -i id_rsa azureuser@<vm-public-ip>
   ```

   Example:
   ```bash
   ssh -i id_rsa azureuser@20.123.45.67
   ```

### Method 3: Using Azure CLI

You can also get the VM's public IP using Azure CLI:
```bash
az vm show -d -g vm-blockchain-rg -n vm-blockchain-vm --query publicIps -o tsv
```

### SSH Connection Troubleshooting

If you encounter SSH connection issues:

1. **Verify the VM is running**:
   ```bash
   az vm show -g vm-blockchain-rg -n vm-blockchain-vm --show-details --query powerState
   ```

2. **Check if the VM has a public IP**:
   ```bash
   az vm show -d -g vm-blockchain-rg -n vm-blockchain-vm --query publicIps
   ```

3. **Verify the SSH key exists and has correct permissions**:
   ```bash
   # Check if the SSH key exists
   ls -la id_rsa
   
   # Set correct permissions if needed
   chmod 600 id_rsa
   ```

4. **Test SSH connectivity**:
   ```bash
   # Test if port 22 is reachable
   telnet <vm-public-ip> 22
   
   # Or use nmap
   nmap -p 22 <vm-public-ip>
   ```

5. **Check Azure Network Security Group**:
   ```bash
   az network nsg rule list -g vm-blockchain-rg --nsg-name vm-blockchain-vm-nsg --query "[?name=='SSH']"
   ```

### First-time SSH Connection

When you first connect to the VM, you may see a security warning:
```
The authenticity of host '20.123.45.67 (20.123.45.67)' can't be established.
ECDSA key fingerprint is SHA256:...
Are you sure you want to continue connecting (yes/no)?
```
Type `yes` to continue.

## Environment Variables

The VM is configured with the following environment variables:
- `OPENAI_API_KEY`: Set to the value provided in terraform.tfvars
- `PATH`: Includes user's local bin directory

You can verify the OpenAI API key is set by running:
```bash
echo $OPENAI_API_KEY
```

## Example Usage

1. **SSH into the VM**:
   ```bash
   ssh -i id_rsa azureuser@<vm-public-ip>
   ```

2. **Verify the installation**:
   ```bash
   # Check if Docker is running
   sudo systemctl status docker
   
   # Check Azure CLI installation
   az --version
   
   # Check OpenAI API key is set
   echo $OPENAI_API_KEY
   
   # Test Docker
   docker run hello-world
   ```

3. **Access your applications on ports 3000 and 8000**:
   ```bash
   # From your local machine, you can access:
   # http://<vm-public-ip>:3000
   # http://<vm-public-ip>:8000
   ```

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

This will remove:
- All Azure resources (VM, network, etc.)
- Generated SSH keys
- Resource group

## Troubleshooting

### Common Issues

1. **VM not accessible via SSH**:
   - Check if the VM is running
   - Verify the public IP is assigned
   - Ensure the SSH key has correct permissions (600)
   - Check NSG rules allow SSH traffic

2. **Docker not working**:
   - Ensure you're in the docker group: `groups`
   - If not, log out and back in, or run: `newgrp docker`

3. **Azure CLI authentication**:
   - The VM has system assigned identity with Owner permissions
   - You can authenticate using: `az login --identity`

4. **OpenAI API key not set**:
   - Check if the variable is set in terraform.tfvars
   - Verify the environment variable: `echo $OPENAI_API_KEY`
   - If not set, you can set it manually: `export OPENAI_API_KEY="your-key"`

### Getting Help

If you encounter issues:
1. Check the Azure portal for resource status
2. Review Terraform logs: `terraform logs`
3. Check VM boot logs: `az vm boot-diagnostics get-boot-log -g <rg> -n <vm-name>`

## Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `resource_group_name` | Name of the resource group | `vm-blockchain-rg` | No |
| `location` | Azure region for resources | `East US` | No |
| `prefix` | Prefix for resource names | `vm-blockchain` | No |
| `vm_size` | Size of the virtual machine | `Standard_B2ms` | No |
| `admin_username` | Admin username for the VM | `azureuser` | No |
| `openai_api_key` | OpenAI API key for environment | - | Yes | 