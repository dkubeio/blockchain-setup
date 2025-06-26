# Azure Managed CCF with VM Terraform Configuration

This Terraform configuration deploys Azure Managed CCF (Confidential Consortium Framework) along with a virtual machine that can access the CCF instance. The configuration automatically generates SSH keys and CCF member certificates.

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

## Deployment

1. **Clone and navigate to the terraform directory**
   ```bash
   cd terraform
   ```

2. **Initialize Terraform**
   ```bash
   terraform init
   ```

3. **Review and customize variables (optional)**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your preferred values
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
- **Network Security Group**: Firewall rules for SSH and HTTPS
- **Public IP**: Public IP address for the VM
- **Network Interface**: Network interface for the VM
- **Virtual Machine**: Ubuntu 22.04 LTS VM with CCF tools installed
- **Managed CCF**: Azure Managed CCF instance
- **SSH Keys**: Automatically generated RSA key pair (4096 bits)
- **CCF Certificates**: Member0 private key and certificate for CCF authentication

## Generated Files

After deployment, the following files will be created in the terraform directory:

- `id_rsa` - SSH private key (permissions: 600)
- `id_rsa.pub` - SSH public key (permissions: 644)
- `member0_privk.pem` - CCF member0 private key (permissions: 600)
- `member0_cert.pem` - CCF member0 certificate (permissions: 644)

**Note**: These files will be automatically deleted when you run `terraform destroy`.

## VM Configuration

The VM is pre-configured with:
- Ubuntu 22.04 LTS
- Docker and Docker Compose
- Azure CLI
- CCF Python package
- Node.js and npm
- Build tools

## Accessing the VM via SSH

### Method 1: Using Terraform Outputs (Recommended)

After deployment, Terraform will display the VM's public IP address and complete SSH command:

```bash
# Get the VM's public IP
terraform output vm_public_ip

# Get the complete SSH command with the correct key
terraform output vm_ssh_command
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
az vm show -d -g ccf-blockchain-rg -n ccf-blockchain-vm --query publicIps -o tsv
```

### SSH Connection Troubleshooting

If you encounter SSH connection issues:

1. **Verify the VM is running**:
   ```bash
   az vm show -g ccf-blockchain-rg -n ccf-blockchain-vm --show-details --query powerState
   ```

2. **Check if the VM has a public IP**:
   ```bash
   az vm show -d -g ccf-blockchain-rg -n ccf-blockchain-vm --query publicIps
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
   az network nsg rule list -g ccf-blockchain-rg --nsg-name ccf-blockchain-vm-nsg --query "[?name=='SSH']"
   ```

### First-time SSH Connection

When you first connect to the VM, you may see a security warning:
```
The authenticity of host '20.123.45.67 (20.123.45.67)' can't be established.
ECDSA key fingerprint is SHA256:...
Are you sure you want to continue connecting (yes/no)?
```
Type `yes` to continue.

## CCF Access

The Managed CCF instance provides several endpoints:
- **Identity URL**: For identity management
- **Identity Service URI**: For identity service operations
- **Application URI**: For application operations
- **Ledger URI**: For ledger operations

These URLs will be displayed in the Terraform outputs.

### CCF Authentication

The configuration generates CCF member certificates that can be used for authentication:

- **Member0 Private Key**: `member0_privk.pem`
- **Member0 Certificate**: `member0_cert.pem`

These certificates follow the CCF specification using ECDSA P384 curve and are valid for 1 year.

## Example Usage

1. **SSH into the VM**:
   ```bash
   ssh -i id_rsa azureuser@<vm-public-ip>
   ```

2. **Verify the installation**:
   ```bash
   # Check if Docker is running
   sudo systemctl status docker
   
   # Check if Azure CLI is installed
   az --version
   
   # Check if CCF is installed
   python3 -c "import ccf; print('CCF installed successfully')"
   ```

3. **Install CCF client** (if not already installed):
   ```bash
   pip3 install ccf
   ```

4. **Access CCF endpoints** using the URLs from Terraform outputs and the generated certificates.

## Cleanup

To destroy all resources and delete generated files:
```bash
terraform destroy
```

This will automatically delete:
- All Azure resources
- Generated SSH keys (`id_rsa`, `id_rsa.pub`)
- Generated CCF certificates (`member0_privk.pem`, `member0_cert.pem`)

## Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `resource_group_name` | Name of the resource group | `ccf-blockchain-rg` |
| `location` | Azure region | `East US` |
| `prefix` | Prefix for resource names | `ccf-blockchain` |
| `vm_size` | VM size | `Standard_D2s_v3` |
| `admin_username` | VM admin username | `azureuser` |
| `ccf_member_count` | Number of CCF members | `3` |
| `app_uri` | CCF application URI | CCF sandbox app |

## Security Notes

- SSH keys are automatically generated and stored locally
- CCF member certificates are generated using ECDSA P384 curve
- All generated files are automatically cleaned up on `terraform destroy`
- The VM has SSH (port 22) and HTTPS (port 443) open
- Consider restricting SSH access to specific IP ranges in production
- The CCF instance uses Azure's managed security features
- All network traffic is encrypted

## Troubleshooting

1. **SSH Connection Issues**: 
   - Ensure you're using the generated SSH key (`id_rsa`)
   - Check if the VM is running and has a public IP
   - Verify network security group rules allow SSH access
   - Ensure the SSH key has correct permissions (600)

2. **CCF Access Issues**: Check the CCF endpoints in Terraform outputs

3. **Resource Creation Failures**: Verify your Azure subscription has sufficient quotas

4. **VM Boot Issues**: Check the VM's boot diagnostics in Azure portal

5. **Certificate Issues**: Verify the generated CCF certificates exist and have correct permissions

## Support

For issues with:
- **Terraform**: Check Terraform documentation
- **Azure Managed CCF**: Refer to Microsoft's CCF documentation
- **VM Access**: Check Azure VM troubleshooting guides
- **SSH Keys**: Verify key permissions and connectivity 