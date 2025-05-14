resource "azurerm_private_endpoint" "this" {
  for_each = { for idx, pe in var.private_endpoints : idx => pe }

  name                          = each.value.private_endpoint_name
  location                      = each.value.location
  resource_group_name           = each.value.rg_name
  subnet_id                     = each.value.subnet_id
  custom_network_interface_name = each.value.custom_network_interface_name
  tags                          = each.value.tags

  dynamic "private_service_connection" {
    for_each = each.value.private_service_connection != null ? [each.value.private_service_connection] : []
    content {
      name                              = private_service_connection.value.name == null ? "pvsvccon-${each.value.private_endpoint_name}" : null
      is_manual_connection              = private_service_connection.value.is_manual_connection
      private_connection_resource_id    = private_service_connection.value.private_connection_resource_id
      private_connection_resource_alias = private_service_connection.value.private_connection_resource_alias
      subresource_names                 = private_service_connection.value.subresource_names
      request_message                   = private_service_connection.value.is_manual_connection == null && private_service_connection.value.request_message == null ? "This is a manual private endpoint connection for ${each.value.private_endpoint_name}" : private_service_connection.value.request_message
    }
  }

  dynamic "private_dns_zone_group" {
    for_each = each.value.private_dns_zone_group != null ? [each.value.private_dns_zone_group] : []
    content {
      name                 = private_dns_zone_group.value.name
      private_dns_zone_ids = private_dns_zone_group.value.private_dns_zone_ids
    }
  }

  dynamic "ip_configuration" {
    for_each = each.value.ip_configuration != null ? [each.value.ip_configuration] : []
    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      subresource_name   = ip_configuration.value.subresource_name
      member_name        = ip_configuration.value.member_name
    }
  }
}

resource "azurerm_application_security_group" "pep_asg" {
  for_each = { for idx, pe in var.private_endpoints : idx => pe if pe.create_asg == true }

  name                = each.value.asg_name != null ? each.value.asg_name : "asg-${each.value.private_endpoint_name}"
  location            = azurerm_private_endpoint.this[each.key].location
  resource_group_name = azurerm_private_endpoint.this[each.key].resource_group_name
  tags                = azurerm_private_endpoint.this[each.key].tags
}

resource "azurerm_private_endpoint_application_security_group_association" "pep_asg_association" {
  for_each                      = { for idx, pe in var.private_endpoints : idx => pe if pe.create_asg == true && pe.create_asg_association == true }
  private_endpoint_id           = azurerm_private_endpoint.this[each.key].id
  application_security_group_id = azurerm_application_security_group.pep_asg[each.key].id
}