output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.project.resource_group_name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = module.project.resource_group_id
}

output "app_service_name" {
  description = "Name of the App Service"
  value       = module.project.app_service_name
}

output "app_service_default_hostname" {
  description = "Default hostname of the App Service (internal use only)"
  value       = module.project.app_service_default_hostname
}

output "app_service_identity_principal_id" {
  description = "Principal ID of the App Service managed identity"
  value       = module.project.app_service_identity_principal_id
}

output "application_gateway_public_ip" {
  description = "Public IP address of the Application Gateway"
  value       = module.project.application_gateway_public_ip
}

output "application_gateway_url" {
  description = "URL to access the application through Application Gateway"
  value       = module.project.application_gateway_url
}

output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = module.project.virtual_network_id
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = module.project.virtual_network_name
}
