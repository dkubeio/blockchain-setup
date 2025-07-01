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

  tags = var.tags
}

resource "azurerm_virtual_network" "vm_vnet" {
  name                = "${var.prefix}-vnet"
  resource_group_name = azurerm_resource_group.vm_rg.name
  location            = azurerm_resource_group.vm_rg.location
  address_space       = ["10.0.0.0/16"]

  tags = var.tags
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

  tags = var.tags
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

  tags = var.tags
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

  tags = var.tags
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

  tags = var.tags
}

# Cleanup generated files on destroy
resource "null_resource" "cleanup_files" {
  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      rm -f ${path.module}/id_rsa
      rm -f ${path.module}/id_rsa.pub
    EOT
  }
} 