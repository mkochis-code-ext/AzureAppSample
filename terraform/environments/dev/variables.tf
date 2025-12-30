variable "environment_prefix" {
  description = "Environment prefix (e.g., dev, prod)"
  type        = string
  default     = "dev"
}

variable "workload" {
  description = "Workload name"
  type        = string
  default     = "webapp"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "data_location" {
  description = "Azure region for data resources (defaults to location if not specified)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project    = "Azure App Sample"
    Owner      = "Platform Team"
    CostCenter = "Engineering"
  }
}

# Network Configuration
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "app_subnet_address_prefix" {
  description = "Address prefix for App Service integration subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "appgw_subnet_address_prefix" {
  description = "Address prefix for Application Gateway subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "pe_subnet_address_prefix" {
  description = "Address prefix for Private Endpoints subnet"
  type        = string
  default     = "10.0.3.0/24"
}

# App Service Configuration
variable "app_service_sku" {
  description = "SKU for the App Service Plan"
  type        = string
  default     = "B1"
}

# Application Gateway Configuration
variable "appgw_sku_name" {
  description = "SKU name for Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "appgw_sku_tier" {
  description = "SKU tier for Application Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "appgw_capacity" {
  description = "Capacity (instance count) for Application Gateway"
  type        = number
  default     = 2
}

variable "ssl_certificate_data" {
  description = "Base64 encoded SSL certificate data (PFX). Generate using Generate-AppGatewayCert.ps1"
  type        = string
  sensitive   = true
}

variable "ssl_certificate_password" {
  description = "Password for the SSL certificate"
  type        = string
  sensitive   = true
}
