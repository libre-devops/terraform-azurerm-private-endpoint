output "private_endpoint_ids" {
  description = "Map of endpoint key to private endpoint id."
  value       = module.private_endpoint.ids
}

output "private_endpoint_names" {
  description = "Map of endpoint key to the auto-derived private endpoint name."
  value       = module.private_endpoint.names
}

output "private_ip_addresses" {
  description = "Map of endpoint key to the endpoint private IP."
  value       = module.private_endpoint.private_ip_addresses
}
