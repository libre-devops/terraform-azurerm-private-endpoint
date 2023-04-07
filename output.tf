output "endpoint_id" {
  value       = azurerm_private_endpoint.endpoint.id
  description = "The ID of the private endpoint"
}

output "endpoint_name" {
  value       = azurerm_private_endpoint.endpoint.name
  description = "The name of the storage account"
}

output "endpoint_network_interface" {
  value       = azurerm_private_endpoint.endpoint.network_interface
  description = "The network interface block"
}


output "endpoint_custom_dns_configs" {
  value       = azurerm_private_endpoint.endpoint.custom_dns_configs
  description = "The custom dns configs block"
}

output "endpoint_private_dns_zone_configs" {
  value       = azurerm_private_endpoint.endpoint.private_dns_zone_configs
  description = "The private dns zone configs"
}

output "endpoint_ip_configuration" {
  value       = azurerm_private_endpoint.endpoint.ip_configuration
  description = "The ip configuration block"
}
