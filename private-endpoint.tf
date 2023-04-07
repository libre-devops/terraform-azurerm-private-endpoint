resource "azurerm_private_endpoint" "endpoint" {
  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = var.rg_name
  subnet_id           = var.subnet_id
  custom_network_interface_name = try(var.custom_network_interface_name, null)
  tags = var.tags


  dynamic "private_service_connection" {
    for_each = var.private_service_connection != null ? [1] : []
    content {
      name = var.private_service_connection["name"]
      is_manual_connection = try(var.private_service_connection["is_manual_connection"], true)
      private_connection_resource_id = try(var.private_service_connection["private_connection_resource_id"], null)
      private_connection_resource_alias = try(var.private_service_connection["private_connection_resource_alias"], null)
      subresource_names = try(var.private_service_connection["subresource_names"], null, [])
      request_message = var.private_service_connection["is_manual_connection"] == true ? try(var.private_service_connection["request_message"], null) : null

    }
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_group != null ? [1] : []
    content {
      name = try(var.private_dns_zone_group["name"], null)
      private_dns_zone_ids = try(var.private_dns_zone_group["private_dns_zone_ids"], null, [])
    }
  }

  dynamic "ip_configuration" {
    for_each = var.ip_configuration != null ? [1] : []
    content {
      name = try(var.ip_configuration["name"], null)
      private_ip_address = try(var.ip_configuration["private_ip_address"], null)
      subresource_name = try(var.ip_configuration["subresource_name"], null)
      member_name = try(var.ip_configuration["member_name"], null)
    }
  }
}

