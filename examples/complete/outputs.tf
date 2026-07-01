output "application_security_group_ids" {
  description = "The application security group ids created for the endpoints."
  value       = module.private_endpoint.application_security_group_ids
}

output "private_endpoint_ids" {
  description = "Map of endpoint key to private endpoint id."
  value       = module.private_endpoint.ids
}

output "private_endpoint_names" {
  description = "Map of endpoint key to the auto-derived private endpoint name."
  value       = module.private_endpoint.names
}

output "tags" {
  description = "The tags applied to the resources."
  value       = module.tags.tags
}
