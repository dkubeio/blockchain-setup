terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.13.1"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
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
  required_version = ">= 1.0"
}

# AWS Provider
provider "aws" {
  region = var.aws_region
  alias  = "default"
}

# Azure Provider
provider "azurerm" {
  features {}
  alias = "default"
}

# Common providers
provider "time" {}
provider "null" {}
provider "random" {}
provider "tls" {}
provider "local" {}

# AWS Module
module "aws" {
  count  = var.cloud_provider == "aws" ? 1 : 0
  source = "./modules/aws"

  # AWS-specific variables
  aws_region        = var.aws_region
  vpc_cidr          = var.vpc_cidr
  ssh_cidr          = var.ssh_cidr
  resource_prefix   = var.resource_prefix
  network_name      = var.network_name
  member_name       = var.member_name
  admin_username    = var.admin_username
  admin_password    = var.admin_password
  github_token      = var.github_token
  openai_api_key    = var.openai_api_key
  tags              = var.tags

  providers = {
    aws     = aws.default
    time    = time
    null    = null
    random  = random
    tls     = tls
    local   = local
  }
}

# Azure Module
module "azure" {
  count  = var.cloud_provider == "azure" ? 1 : 0
  source = "./modules/azure"

  # Azure-specific variables
  resource_group_name = var.azure_resource_group_name
  location           = var.azure_location
  prefix             = var.azure_prefix
  vm_size            = var.azure_vm_size
  admin_username     = var.admin_username
  ccf_member_count   = var.azure_ccf_member_count
  openai_api_key     = var.openai_api_key

  providers = {
    azurerm = azurerm.default
    tls     = tls
    local   = local
  }
} 