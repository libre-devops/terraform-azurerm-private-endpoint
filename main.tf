# Private endpoints keyed by a logical name. Names default to pep-<subresource>-<target resource> (the
# target resource name is parsed from the connection id) and the NIC to nic-pep-.... The private DNS
# zone group is either given explicitly or auto-resolved from the module-level private_dns_zone_ids map
# by subresource (the portable form of a central-hub DNS lookup). Optionally create an application
# security group and associate the endpoint with it. The resource group is passed by id and parsed.

resource "azurerm_private_endpoint" "this" {
  for_each = local.resolved

  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags

  name                          = each.value.name
  subnet_id                     = each.value.subnet_id
  custom_network_interface_name = each.value.nic_name

  private_service_connection {
    name                              = coalesce(each.value.private_service_connection.name, "pvsc-${each.value.name}")
    is_manual_connection              = each.value.private_service_connection.is_manual_connection
    private_connection_resource_id    = each.value.private_service_connection.private_connection_resource_id
    private_connection_resource_alias = each.value.private_service_connection.private_connection_resource_alias
    # A PLS target sends no groupIds; null keeps the payload clean rather than an empty list.
    subresource_names = each.value.private_service_connection.is_private_link_service ? null : each.value.private_service_connection.subresource_names
    request_message   = each.value.private_service_connection.is_manual_connection ? each.value.private_service_connection.request_message : null
  }

  dynamic "private_dns_zone_group" {
    for_each = each.value.dns_zone_ids != null ? [1] : []

    content {
      name                 = each.value.dns_zone_name
      private_dns_zone_ids = each.value.dns_zone_ids
    }
  }

  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      subresource_name   = ip_configuration.value.subresource_name
      member_name        = ip_configuration.value.member_name
    }
  }
}

resource "azurerm_application_security_group" "this" {
  for_each = { for k, pe in local.resolved : k => pe if pe.create_asg }

  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags

  name = coalesce(each.value.asg_name, "asg-${each.value.name}")
}

resource "azurerm_private_endpoint_application_security_group_association" "this" {
  for_each = { for k, pe in local.resolved : k => pe if pe.create_asg }

  private_endpoint_id           = azurerm_private_endpoint.this[each.key].id
  application_security_group_id = azurerm_application_security_group.this[each.key].id
}
