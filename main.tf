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
      name                              = lookup(private_service_connection.value, "name", null) == null ? "pvsvccon-${each.value.private_endpoint_name}" : null
      is_manual_connection              = lookup(private_service_connection.value, "is_manual_connection", true)
      private_connection_resource_id    = lookup(private_service_connection.value, "private_connection_resource_id", null)
      private_connection_resource_alias = lookup(private_service_connection.value, "private_connection_resource_alias", null)
      subresource_names                 = lookup(private_service_connection.value, "subresource_names", [])
      request_message = private_service_connection.value.is_manual_connection && lookup(private_service_connection.value, "request_message", null) == null ? "This is a manual private endpoint connection for ${each.value.private_endpoint_name}" : lookup(private_service_connection.value, "request_message", null)
    }
  }

  dynamic "private_dns_zone_group" {
    for_each = each.value.private_dns_zone_group != null ? [each.value.private_dns_zone_group] : []
    content {
      name                 = lookup(private_dns_zone_group.value, "name", null)
      private_dns_zone_ids = lookup(private_dns_zone_group.value, "private_dns_zone_ids", [])
    }
  }

  dynamic "ip_configuration" {
    for_each = each.value.ip_configuration != null ? [each.value.ip_configuration] : []
    content {
      name               = lookup(ip_configuration.value, "name", null)
      private_ip_address = lookup(ip_configuration.value, "private_ip_address", null)
      subresource_name   = lookup(ip_configuration.value, "subresource_name", null)
      member_name        = lookup(ip_configuration.value, "member_name", null)
    }
  }
}
