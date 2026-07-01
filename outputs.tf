output "application_security_group_ids" {
  description = "Map of endpoint key to the application security group id (only endpoints with create_asg)."
  value       = { for k, a in azurerm_application_security_group.this : k => a.id }
}

output "ids" {
  description = "Map of endpoint key to the private endpoint id."
  value       = { for k, p in azurerm_private_endpoint.this : k => p.id }
}

output "ids_zipmap" {
  description = "Map of endpoint key to a { name, id } object, for passing where both are needed together."
  value       = { for k, p in azurerm_private_endpoint.this : k => { name = p.name, id = p.id } }
}

output "names" {
  description = "Map of endpoint key to the private endpoint's actual name (pep-<subresource>-<resource> when auto-derived)."
  value       = { for k, p in azurerm_private_endpoint.this : k => p.name }
}

output "private_dns_zone_configs" {
  description = "Map of endpoint key to its private DNS zone group's recorded zone configs (fqdn and record sets), when a DNS zone group is attached."
  value       = { for k, p in azurerm_private_endpoint.this : k => p.private_dns_zone_group }
}

output "private_ip_addresses" {
  description = "Map of endpoint key to the endpoint's primary private IP address."
  value       = { for k, p in azurerm_private_endpoint.this : k => try(p.private_service_connection[0].private_ip_address, null) }
}

output "resource_group_name" {
  description = "Resource group name parsed from resource_group_id."
  value       = local.resource_group_name
}

output "subscription_id" {
  description = "Subscription id parsed from resource_group_id."
  value       = local.rg.subscription_id
}

output "tags" {
  description = "The tags applied to the private endpoints."
  value       = var.tags
}
