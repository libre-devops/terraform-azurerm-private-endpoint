# check blocks run after every plan and apply and emit a warning (without blocking) when an
# invariant is violated. They are the place to enforce module-wide consistency.

# The module does nothing without at least one private endpoint.
check "has_private_endpoints" {
  assert {
    condition     = length(var.private_endpoints) > 0
    error_message = "No private_endpoints were supplied, so this module creates nothing."
  }
}

# A private endpoint without DNS resolution usually cannot be reached by name. Warn when an endpoint has
# neither an explicit nor an auto-resolvable private DNS zone group (unless the connection is manual,
# or targets a private link service, which has no privatelink zone: consumers use the endpoint IP).
check "endpoints_resolve_dns" {
  assert {
    condition = alltrue([
      for pe in values(local.resolved) :
      pe.private_service_connection.is_manual_connection || pe.private_service_connection.is_private_link_service || pe.dns_zone_ids != null
    ])
    error_message = "A private endpoint has no private DNS zone group and none could be auto-resolved (subresource not in private_dns_zone_ids). Clients will not resolve it by name; set private_dns_zone_group, add the subresource to private_dns_zone_ids with auto_dns_zone_group = true, or manage DNS elsewhere."
  }
}
