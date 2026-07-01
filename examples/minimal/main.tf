locals {
  location    = lookup(var.regions, var.loc, "uksouth")
  rg_name     = "rg-${var.short}-${var.loc}-${terraform.workspace}-001"
  vnet_name   = "vnet-${var.short}-${var.loc}-${terraform.workspace}-001"
  sa_name     = "st${var.short}${var.loc}${terraform.workspace}001"
  subnet_name = "snet-pe-${local.vnet_name}"
}

module "tags" {
  source  = "libre-devops/tags/azurerm"
  version = "~> 4.0"

  cost_centre     = "1888/67"
  owner           = "platform@example.com"
  deployed_branch = var.deployed_branch
  deployed_repo   = var.deployed_repo
}

module "rg" {
  source  = "libre-devops/rg/azurerm"
  version = "~> 4.0"

  resource_groups = [{ name = local.rg_name, location = local.location, tags = module.tags.tags }]
}

module "network" {
  source  = "libre-devops/network/azurerm"
  version = "~> 4.0"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  vnet_name     = local.vnet_name
  address_space = ["10.0.0.0/16"]
  subnets = {
    (local.subnet_name) = {
      address_prefixes                  = ["10.0.1.0/24"]
      private_endpoint_network_policies = "Disabled"
    }
  }
}

# The resource to lock down behind a private endpoint.
module "storage" {
  source  = "libre-devops/storage-account/azurerm"
  version = "~> 4.0"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  storage_accounts = { (local.sa_name) = { public_network_access_enabled = false } }
}

# The private DNS zone the endpoint registers into (must be the exact privatelink zone name).
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = module.rg.names[local.rg_name]
  tags                = module.tags.tags
}

# Minimal call: a private endpoint to the storage account's blob service, with an explicit DNS zone
# group. The name auto-derives to pep-blob-<account name>.
module "private_endpoint" {
  source = "../../"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  private_endpoints = {
    "blob" = {
      subnet_id = module.network.subnet_ids[local.subnet_name]
      private_service_connection = {
        private_connection_resource_id = module.storage.ids[local.sa_name]
        subresource_names              = ["blob"]
      }
      private_dns_zone_group = {
        private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
      }
    }
  }
}
