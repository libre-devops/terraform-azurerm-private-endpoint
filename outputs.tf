output "private_endpoint_custom_network_interface_names" {
  description = "The custom network interface names of the created Azure Private Endpoints."
  value = {
    for key, pe in azurerm_private_endpoint.this :
    key.name => pe.custom_network_interface_name
  }
}

output "private_endpoint_ids" {
  description = "The IDs of the created Azure Private Endpoints."
  value = {
    for key, pe in azurerm_private_endpoint.this :
    key.name => pe.id
  }
}

output "private_endpoint_locations" {
  description = "The locations of the created Azure Private Endpoints."
  value = {
    for key, pe in azurerm_private_endpoint.this :
    key.name => pe.location
  }
}

output "private_endpoint_names" {
  description = "The names of the created Azure Private Endpoints."
  value = {
    for key, pe in azurerm_private_endpoint.this :
    key.name => pe.name
  }
}

output "private_endpoint_rg_names" {
  description = "The resource group names of the created Azure Private Endpoints."
  value = {
    for key, pe in azurerm_private_endpoint.this :
    key.name => pe.resource_group_name
  }
}

output "private_endpoint_subnet_ids" {
  description = "The subnet IDs of the created Azure Private Endpoints."
  value = {
    for key, pe in azurerm_private_endpoint.this :
    key.name => pe.subnet_id
  }
}

output "private_endpoint_tags" {
  description = "The tags associated with the created Azure Private Endpoints."
  value = {
    for key, pe in azurerm_private_endpoint.this :
    key.name => pe.tags
  }
}
