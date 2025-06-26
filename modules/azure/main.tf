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
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.13.1"
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

# Generate CCF member certificates
resource "tls_private_key" "member0_key" {
  algorithm = "ECDSA"
  ecdsa_curve = "P384"
}

resource "tls_self_signed_cert" "member0_cert" {
  private_key_pem = tls_private_key.member0_key.private_key_pem
  
  subject {
    common_name = "member0"
  }
  
  validity_period_hours = 8760 # 1 year
  
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

# Save CCF member private key
resource "local_file" "member0_privk" {
  content         = tls_private_key.member0_key.private_key_pem
  filename        = "${path.module}/member0_privk.pem"
  file_permission = "0600"
}

# Save CCF member certificate
resource "local_file" "member0_cert" {
  content         = tls_self_signed_cert.member0_cert.cert_pem
  filename        = "${path.module}/member0_cert.pem"
  file_permission = "0644"
}

# Resource Group
resource "azurerm_resource_group" "ccf_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "ccf_vnet" {
  name                = "${var.prefix}-vnet"
  resource_group_name = azurerm_resource_group.ccf_rg.name
  location            = azurerm_resource_group.ccf_rg.location
  address_space       = ["10.0.0.0/16"]
}

# Subnet for VM
resource "azurerm_subnet" "vm_subnet" {
  name                 = "${var.prefix}-vm-subnet"
  resource_group_name  = azurerm_resource_group.ccf_rg.name
  virtual_network_name = azurerm_virtual_network.ccf_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Network Security Group for VM
resource "azurerm_network_security_group" "vm_nsg" {
  name                = "${var.prefix}-vm-nsg"
  location            = azurerm_resource_group.ccf_rg.location
  resource_group_name = azurerm_resource_group.ccf_rg.name

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
    name                       = "HTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG with subnet
resource "azurerm_subnet_network_security_group_association" "vm_nsg_association" {
  subnet_id                 = azurerm_subnet.vm_subnet.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

# Public IP for VM
resource "azurerm_public_ip" "vm_pip" {
  name                = "${var.prefix}-vm-pip"
  resource_group_name = azurerm_resource_group.ccf_rg.name
  location            = azurerm_resource_group.ccf_rg.location
  allocation_method   = "Dynamic"
}

# Network Interface for VM
resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.prefix}-vm-nic"
  location            = azurerm_resource_group.ccf_rg.location
  resource_group_name = azurerm_resource_group.ccf_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip.id
  }
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "ccf_vm" {
  name                = "${var.prefix}-vm"
  resource_group_name = azurerm_resource_group.ccf_rg.name
  location            = azurerm_resource_group.ccf_rg.location
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
  }))
}

# Create Managed CCF using Azure CLI
resource "null_resource" "create_ccf" {
  depends_on = [azurerm_resource_group.ccf_rg]

  triggers = {
    resource_group_name = var.resource_group_name
    ccf_name           = "${var.prefix}-ccf"
    location           = var.location
    member_count       = var.ccf_member_count
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Check if CCF already exists
      EXISTING_CCF=$(az ccf show \
        --name "${var.prefix}-ccf" \
        --resource-group "${var.resource_group_name}" \
        --query "name" \
        --output tsv 2>/dev/null || echo "")
      
      if [ -z "$EXISTING_CCF" ]; then
        echo "Creating new CCF instance..."
        az ccf create \
          --name "${var.prefix}-ccf" \
          --resource-group "${var.resource_group_name}" \
          --location "${var.location}" \
          --member-count ${var.ccf_member_count} \
          --deployment-type "Dev" \
          --app-name "${var.prefix}-app" \
          --app-uri "${var.app_uri}" \
          --language-runtime "CPP"
      else
        echo "CCF instance '${var.prefix}-ccf' already exists"
      fi
    EOT
  }
}

# Get CCF information using Azure CLI
data "external" "ccf_info" {
  depends_on = [null_resource.create_ccf]
  
  program = ["bash", "-c", <<-EOT
    # Get CCF details
    CCF_ID=$(az ccf show \
      --name "${var.prefix}-ccf" \
      --resource-group "${var.resource_group_name}" \
      --query "id" \
      --output tsv)
    
    IDENTITY_URL=$(az ccf show \
      --name "${var.prefix}-ccf" \
      --resource-group "${var.resource_group_name}" \
      --query "properties.identityUrl" \
      --output tsv)
    
    IDENTITY_SERVICE_URI=$(az ccf show \
      --name "${var.prefix}-ccf" \
      --resource-group "${var.resource_group_name}" \
      --query "properties.identityServiceUri" \
      --output tsv)
    
    APP_URI=$(az ccf show \
      --name "${var.prefix}-ccf" \
      --resource-group "${var.resource_group_name}" \
      --query "properties.appUri" \
      --output tsv)
    
    LEDGER_URI=$(az ccf show \
      --name "${var.prefix}-ccf" \
      --resource-group "${var.resource_group_name}" \
      --query "properties.ledgerUri" \
      --output tsv)
    
    # Output as JSON with proper escaping
    printf '{"ccf_id":"%s","identity_url":"%s","identity_service_uri":"%s","app_uri":"%s","ledger_uri":"%s"}' \
      "$CCF_ID" "$IDENTITY_URL" "$IDENTITY_SERVICE_URI" "$APP_URI" "$LEDGER_URI"
  EOT
  ]
}

# Wait for CCF to be ready
resource "time_sleep" "wait_for_ccf" {
  depends_on = [null_resource.create_ccf]
  create_duration = "60s"
}

# Cleanup CCF resources
resource "null_resource" "cleanup_ccf" {
  depends_on = [null_resource.create_ccf]

  triggers = {
    resource_group_name = var.resource_group_name
    ccf_name           = "${var.prefix}-ccf"
  }

  # This will run during terraform destroy
  provisioner "local-exec" {
    when = destroy

    command = <<-EOT
      echo "Deleting CCF instance ${self.triggers.ccf_name}..."
      az ccf delete \
        --name "${self.triggers.ccf_name}" \
        --resource-group "${self.triggers.resource_group_name}" \
        --yes
      
      echo "Waiting for CCF instance to be deleted..."
      while true; do
        if ! az ccf show \
          --name "${self.triggers.ccf_name}" \
          --resource-group "${self.triggers.resource_group_name}" \
          --query "name" \
          --output tsv 2>/dev/null | grep -q "${self.triggers.ccf_name}"; then
          echo "CCF instance has been deleted"
          break
        fi
        echo "CCF instance still exists, waiting..."
        sleep 30
      done
    EOT
  }
} 