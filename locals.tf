locals {
  rg                  = provider::azurerm::parse_resource_id(var.resource_group_id)
  resource_group_name = local.rg.resource_group_name

  # Resolve each private endpoint: derive names from the target resource (parsed from its id) and the
  # subresource, and resolve the private DNS zone group (explicit, or auto-looked-up from the
  # module-level private_dns_zone_ids map by subresource). This is the portable version of the "clever"
  # lookup: the caller supplies the subresource -> zone id map (typically their hub's private DNS zones).
  private_endpoints = {
    for k, pe in var.private_endpoints : k => merge(pe, {
      # First subresource drives naming and the auto DNS zone lookup; "svc" when none is given.
      _subresource = try(pe.private_service_connection.subresource_names[0], "svc")
      # Target resource name parsed from the connection id; falls back to the map key for alias connections.
      _target = try(provider::azurerm::parse_resource_id(pe.private_service_connection.private_connection_resource_id).resource_name, k)
    })
  }

  # Second pass so names/dns can reference the derived _subresource / _target.
  resolved = {
    for k, pe in local.private_endpoints : k => merge(pe, {
      name          = coalesce(pe.name, "pep-${replace(pe._subresource, "_", "-")}-${pe._target}")
      nic_name      = coalesce(pe.custom_network_interface_name, "nic-pep-${replace(pe._subresource, "_", "-")}-${pe._target}")
      dns_zone_name = coalesce(try(pe.private_dns_zone_group.name, null), "default")

      dns_zone_ids = (
        pe.private_dns_zone_group != null ? pe.private_dns_zone_group.private_dns_zone_ids :
        (pe.auto_dns_zone_group && contains(keys(var.private_dns_zone_ids), pe._subresource)) ? [var.private_dns_zone_ids[pe._subresource]] :
        null
      )
    })
  }
}
