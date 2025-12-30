terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Generate random suffix for uniqueness
resource "random_string" "suffix" {
  length  = 3
  special = false
  upper   = false
}

locals {
  suffix = random_string.suffix.result
  tags = merge(
    var.tags,
    {
      Environment = var.environment_prefix
      ManagedBy   = "Terraform"
    }
  )
}

# Call project module
module "project" {
  source = "../../project"

  environment_prefix = var.environment_prefix
  suffix             = local.suffix
  tags               = local.tags
  workload           = var.workload
  location           = var.location
  data_location      = var.data_location

  # Network configuration
  vnet_address_space            = var.vnet_address_space
  app_subnet_address_prefix     = var.app_subnet_address_prefix
  appgw_subnet_address_prefix   = var.appgw_subnet_address_prefix
  pe_subnet_address_prefix      = var.pe_subnet_address_prefix

  # App Service configuration
  app_service_sku = var.app_service_sku

  # Application Gateway configuration
  appgw_sku_name           = var.appgw_sku_name
  appgw_sku_tier           = var.appgw_sku_tier
  appgw_capacity           = var.appgw_capacity
  ssl_certificate_data     = var.ssl_certificate_data
  ssl_certificate_password = var.ssl_certificate_password
}
