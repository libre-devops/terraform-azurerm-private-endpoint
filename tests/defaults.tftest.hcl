# Plan-time tests for the module. The azurerm provider is mocked, so no credentials, no
# features block, and no cloud calls are needed:
#   terraform init -backend=false && terraform test

mock_provider "azurerm" {}

variables {
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ldo-uks-tst-001"
  location          = "uksouth"

  private_dns_zone_ids = {
    blob = "/subscriptions/0000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
  }

  private_endpoints = {
    "kv" = {
      subnet_id = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet-pe"
      private_service_connection = {
        private_connection_resource_id = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/kv-ldo-uks-tst-001"
        subresource_names              = ["vault"]
      }
      private_dns_zone_group = {
        private_dns_zone_ids = ["/subscriptions/0000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"]
      }
    }
  }
}

run "auto_names_from_target_and_subresource" {
  command = plan

  assert {
    condition     = azurerm_private_endpoint.this["kv"].name == "pep-vault-kv-ldo-uks-tst-001"
    error_message = "The endpoint name should default to pep-<subresource>-<target resource name>."
  }

  assert {
    condition     = azurerm_private_endpoint.this["kv"].custom_network_interface_name == "nic-pep-vault-kv-ldo-uks-tst-001"
    error_message = "The NIC name should default to nic-pep-<subresource>-<target resource name>."
  }

  assert {
    condition     = length(azurerm_private_endpoint.this["kv"].private_dns_zone_group) == 1
    error_message = "An explicit private DNS zone group should be attached."
  }
}

run "auto_resolves_dns_zone_and_asg" {
  command = plan

  variables {
    private_endpoints = {
      "blob" = {
        subnet_id           = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet-pe"
        auto_dns_zone_group = true
        create_asg          = true
        private_service_connection = {
          private_connection_resource_id = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.Storage/storageAccounts/stldoukstst001"
          subresource_names              = ["blob"]
        }
      }
    }
  }

  assert {
    condition     = length(azurerm_private_endpoint.this["blob"].private_dns_zone_group) == 1
    error_message = "The DNS zone group should be auto-resolved from private_dns_zone_ids for the blob subresource."
  }

  assert {
    condition     = length(azurerm_application_security_group.this) == 1 && length(azurerm_private_endpoint_application_security_group_association.this) == 1
    error_message = "create_asg should create an ASG and its association."
  }
}

run "rejects_both_id_and_alias" {
  command = plan

  variables {
    private_endpoints = {
      "bad" = {
        subnet_id = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet-pe"
        private_service_connection = {
          private_connection_resource_id    = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/kv"
          private_connection_resource_alias = "some-alias"
          subresource_names                 = ["vault"]
        }
      }
    }
  }

  expect_failures = [var.private_endpoints]
}

run "rejects_non_manual_without_subresource" {
  command = plan

  variables {
    private_endpoints = {
      "bad" = {
        subnet_id = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet/subnets/snet-pe"
        private_service_connection = {
          private_connection_resource_id = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/kv"
        }
      }
    }
  }

  expect_failures = [var.private_endpoints]
}

run "allows_a_private_link_service_connection_without_subresources" {
  command = plan

  variables {
    private_endpoints = {
      consumer = {
        subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ldo-uks-tst-pep-01/providers/Microsoft.Network/virtualNetworks/vnet-ldo-uks-tst-01/subnets/snet-pep"

        private_service_connection = {
          private_connection_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ldo-uks-tst-pep-01/providers/Microsoft.Network/privateLinkServices/pl-ldo-uks-tst-001"
          is_private_link_service        = true
        }
      }
    }
  }

  assert {
    condition     = azurerm_private_endpoint.this["consumer"].private_service_connection[0].subresource_names == null
    error_message = "A PLS connection should send no subresource names."
  }
}

run "rejects_a_private_link_service_connection_with_subresources" {
  command = plan

  variables {
    private_endpoints = {
      consumer = {
        subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ldo-uks-tst-pep-01/providers/Microsoft.Network/virtualNetworks/vnet-ldo-uks-tst-01/subnets/snet-pep"

        private_service_connection = {
          private_connection_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ldo-uks-tst-pep-01/providers/Microsoft.Network/privateLinkServices/pl-ldo-uks-tst-001"
          is_private_link_service        = true
          subresource_names              = ["vault"]
        }
      }
    }
  }

  expect_failures = [var.private_endpoints]
}
