# Azure Terraform configuration file
# Copy this file and modify the values as needed
# Note: Secrets (openai_api_key) and provider are passed via command line

# Azure Configuration
resource_group_name = "vm-blockchain-rg"
location           = "East US"
prefix             = "vm-blockchain"
vm_size            = "Standard_B2ms"
admin_username     = "azureuser" 