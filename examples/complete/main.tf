locals {
  location    = lookup(var.regions, var.loc, "uksouth")
  rg_name     = "rg-${var.short}-${var.loc}-${terraform.workspace}-002"
  vnet_name   = "vnet-${var.short}-${var.loc}-${terraform.workspace}-002"
  sa_name     = "st${var.short}${var.loc}${terraform.workspace}002"
  subnet_name = "snet-pe-${local.vnet_name}"
}

module "tags" {
  source  = "libre-devops/tags/azurerm"
  version = "~> 4.0"

  environment     = "prd"
  cost_centre     = "1888/67"
  owner           = "platform@example.com"
  deployed_branch = var.deployed_branch
  deployed_repo   = var.deployed_repo
  additional_tags = { Application = "terraform-azurerm-private-endpoint" }
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
  address_space = ["10.1.0.0/16"]
  subnets = {
    (local.subnet_name) = {
      address_prefixes                  = ["10.1.1.0/24"]
      private_endpoint_network_policies = "Disabled"
    }
  }
}

module "storage" {
  source  = "libre-devops/storage-account/azurerm"
  version = "~> 4.0"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  storage_accounts = { (local.sa_name) = { public_network_access_enabled = false } }
}

# In a real deployment these private DNS zones live in a central hub; here the example creates one and
# feeds its id into the module's subresource -> zone map so auto_dns_zone_group can resolve it.
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = module.rg.names[local.rg_name]
  tags                = module.tags.tags
}

# Complete call: a private endpoint that auto-resolves its DNS zone group from private_dns_zone_ids by
# subresource, and also creates an application security group and associates the endpoint with it.
module "private_endpoint" {
  source = "../../"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  # subresource -> private DNS zone id (typically your hub's zones).
  private_dns_zone_ids = {
    blob = azurerm_private_dns_zone.blob.id
  }

  private_endpoints = {
    "blob" = {
      subnet_id           = module.network.subnet_ids[local.subnet_name]
      auto_dns_zone_group = true
      create_asg          = true
      private_service_connection = {
        private_connection_resource_id = module.storage.ids[local.sa_name]
        subresource_names              = ["blob"]
      }
    }
  }
}
