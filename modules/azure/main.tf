terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~>2.0"
    }
  }
}

# Generate SSH key pair
resource "tls_private_key" "vm_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save SSH private key to file
resource "local_file" "ssh_private_key" {
  content         = tls_private_key.vm_ssh_key.private_key_pem
  filename        = "${path.module}/id_rsa"
  file_permission = "0600"
}

# Save SSH public key to file
resource "local_file" "ssh_public_key" {
  content         = tls_private_key.vm_ssh_key.public_key_openssh
  filename        = "${path.module}/id_rsa.pub"
  file_permission = "0644"
}

# Azure Resources
resource "azurerm_resource_group" "vm_rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Name        = var.resource_group_name
    Environment = "blockchain-setup"
    ManagedBy   = "terraform"
  }
}

resource "azurerm_virtual_network" "vm_vnet" {
  name                = "${var.prefix}-vnet"
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = azurerm_resource_group.vm_rg.location
  address_space       = ["10.0.0.0/16"]

  tags = {
    Name        = "${var.prefix}-vnet"
    Environment = "blockchain-setup"
    ManagedBy   = "terraform"
  }
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.vm_rg.name
  virtual_network_name = azurerm_virtual_network.vm_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "vm_nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Port-3000"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Port-8000"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Name        = "${var.prefix}-nsg"
    Environment = "blockchain-setup"
    ManagedBy   = "terraform"
  }
}

resource "azurerm_subnet_network_security_group_association" "vm_nsg_association" {
  subnet_id                 = azurerm_subnet.vm_subnet.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

resource "azurerm_public_ip" "vm_pip" {
  name                = "${var.prefix}-pip"
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name
  allocation_method   = "Dynamic"

  tags = {
    Name        = "${var.prefix}-pip"
    Environment = "blockchain-setup"
    ManagedBy   = "terraform"
  }
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.vm_rg.location
  resource_group_name = azurerm_resource_group.vm_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip.id
  }

  tags = {
    Name        = "${var.prefix}-nic"
    Environment = "blockchain-setup"
    ManagedBy   = "terraform"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "${var.prefix}-vm"
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = azurerm_resource_group.vm_rg.location
  size                = var.vm_size
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.vm_ssh_key.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(templatefile("${path.module}/cloud-init.tpl", {
    admin_username = var.admin_username
    openai_api_key = var.openai_api_key
  }))

  tags = {
    Name        = "${var.prefix}-vm"
    Environment = "blockchain-setup"
    ManagedBy   = "terraform"
  }
}

# Create Managed CCF instance using Azure CLI
resource "null_resource" "create_ccf" {
  depends_on = [azurerm_linux_virtual_machine.vm]

  provisioner "local-exec" {
    command = <<-EOT
      # Check if CCF instance already exists
      EXISTING_CCF=$(az ccf list --resource-group ${var.resource_group_name} --query "[?name=='${var.prefix}-ccf'].name" --output tsv)
      
      if [ -z "$EXISTING_CCF" ]; then
        echo "Creating new CCF instance..."
        az ccf create \
          --name "${var.prefix}-ccf" \
          --resource-group "${var.resource_group_name}" \
          --location "${var.location}" \
          --member-count ${var.ccf_member_count} \
          --member-certificate-subject-name "CN=CCF Member" \
          --member-certificate-validity-in-years 1
      else
        echo "CCF instance '${var.prefix}-ccf' already exists"
      fi
    EOT
  }
}

# Get CCF information
data "external" "ccf_info" {
  depends_on = [null_resource.create_ccf]
  
  program = ["bash", "-c", <<-EOT
    # Get CCF details
    CCF_ID=$(az ccf show --name "${var.prefix}-ccf" --resource-group "${var.resource_group_name}" --query "id" --output tsv)
    IDENTITY_URL=$(az ccf show --name "${var.prefix}-ccf" --resource-group "${var.resource_group_name}" --query "properties.identityServiceUri" --output tsv)
    APP_URI=$(az ccf show --name "${var.prefix}-ccf" --resource-group "${var.resource_group_name}" --query "properties.appUri" --output tsv)
    LEDGER_URI=$(az ccf show --name "${var.prefix}-ccf" --resource-group "${var.resource_group_name}" --query "properties.ledgerUri" --output tsv)
    
    # Output as JSON
    printf '{"ccf_id":"%s","identity_url":"%s","app_uri":"%s","ledger_uri":"%s"}' "$CCF_ID" "$IDENTITY_URL" "$APP_URI" "$LEDGER_URI"
  EOT
  ]
}

# Generate member certificates
resource "null_resource" "generate_member_certs" {
  depends_on = [data.external.ccf_info]

  provisioner "local-exec" {
    command = <<-EOT
      # Generate member0 private key and certificate
      openssl genrsa -out ${path.module}/member0_privk.pem 2048
      openssl req -new -key ${path.module}/member0_privk.pem -out ${path.module}/member0_cert.csr -subj "/CN=CCF Member 0"
      openssl x509 -req -in ${path.module}/member0_cert.csr -signkey ${path.module}/member0_privk.pem -out ${path.module}/member0_cert.pem -days 365
      
      # Clean up CSR file
      rm ${path.module}/member0_cert.csr
    EOT
  }
}

# Cleanup generated files on destroy
resource "null_resource" "cleanup_files" {
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      rm -f ${path.module}/id_rsa
      rm -f ${path.module}/id_rsa.pub
      rm -f ${path.module}/member0_privk.pem
      rm -f ${path.module}/member0_cert.pem
    EOT
  }
} 