variable "location" {
  description = "Azure region for the private endpoints."
  type        = string
}

variable "private_dns_zone_ids" {
  description = "Map of subresource name (for example vault, blob, file, sqlServer) to the private DNS zone resource id to use for it (typically your hub's private DNS zones). Used to auto-resolve a private endpoint's DNS zone group when auto_dns_zone_group is true."
  type        = map(string)
  default     = {}
}

variable "private_endpoints" {
  description = <<-EOT
    Private endpoints to create, keyed by a logical name.

    name defaults to pep-<subresource>-<target resource> (the target resource name is parsed from the
    connection id) and custom_network_interface_name to nic-pep-<...>.

    DNS: give private_dns_zone_group explicitly, or set auto_dns_zone_group = true to look the zone id up
    by subresource from the module-level private_dns_zone_ids map. Set create_asg = true to also create an
    application security group and associate the endpoint with it.
  EOT
  type = map(object({
    subnet_id                     = string
    name                          = optional(string)
    custom_network_interface_name = optional(string)
    auto_dns_zone_group           = optional(bool, false)
    create_asg                    = optional(bool, false)
    asg_name                      = optional(string)

    private_service_connection = object({
      name                              = optional(string)
      is_manual_connection              = optional(bool, false)
      private_connection_resource_id    = optional(string)
      private_connection_resource_alias = optional(string)
      subresource_names                 = optional(list(string))
      request_message                   = optional(string)
    })

    private_dns_zone_group = optional(object({
      name                 = optional(string, "default")
      private_dns_zone_ids = list(string)
    }))

    ip_configurations = optional(list(object({
      name               = string
      private_ip_address = string
      subresource_name   = optional(string)
      member_name        = optional(string)
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for pe in values(var.private_endpoints) :
      (pe.private_service_connection.private_connection_resource_id != null) != (pe.private_service_connection.private_connection_resource_alias != null)
    ])
    error_message = "Each private_service_connection must set exactly one of private_connection_resource_id or private_connection_resource_alias."
  }

  validation {
    condition = alltrue([
      for pe in values(var.private_endpoints) :
      pe.private_service_connection.is_manual_connection ? true : (pe.private_service_connection.subresource_names != null && length(coalesce(pe.private_service_connection.subresource_names, [])) > 0)
    ])
    error_message = "A non-manual private_service_connection must set subresource_names (for example [\"vault\"] or [\"blob\"])."
  }
}

variable "resource_group_id" {
  description = "Resource id of the resource group to create the private endpoints in. The name and subscription are parsed from it (pass the rg module's ids output)."
  type        = string

  validation {
    condition     = try(provider::azurerm::parse_resource_id(var.resource_group_id).resource_type, "") == "resourceGroups"
    error_message = "resource_group_id must be a resource group id of the form /subscriptions/<sub>/resourceGroups/<name>."
  }
}

variable "tags" {
  description = "Tags to apply to the private endpoints."
  type        = map(string)
  default     = {}
}
