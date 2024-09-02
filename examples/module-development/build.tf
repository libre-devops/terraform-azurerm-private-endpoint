module "rg" {
  source = "libre-devops/rg/azurerm"

  rg_name  = "rg-${var.short}-${var.loc}-${var.env}-01"
  location = local.location
  tags     = local.tags
}

module "shared_vars" {
  source = "libre-devops/shared-vars/azurerm"
}

locals {
  lookup_cidr = {
    for landing_zone, envs in module.shared_vars.cidrs : landing_zone => {
      for env, cidr in envs : env => cidr
    }
  }
}

module "subnet_calculator" {
  source = "libre-devops/subnet-calculator/null"

  base_cidr    = local.lookup_cidr[var.short][var.env][0]
  subnet_sizes = [26]
}

module "network" {
  source = "libre-devops/network/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  vnet_name          = "vnet-${var.short}-${var.loc}-${var.env}-01"
  vnet_location      = module.rg.rg_location
  vnet_address_space = [module.subnet_calculator.base_cidr]

  subnets = {
    for i, name in module.subnet_calculator.subnet_names :
    name => {
      address_prefixes  = toset([module.subnet_calculator.subnet_ranges[i]])
      service_endpoints = ["Microsoft.KeyVault", "Microsoft.Storage"]
    }
  }
}

data "http" "user_ip" {
  url = "https://checkip.amazonaws.com"
}


module "role_assignments" {
  source = "libre-devops/role-assignment/azurerm"

  role_assignments = [
    {
      principal_ids = [data.azurerm_client_config.current.object_id]
      role_names    = ["Key Vault Administrator"]
      scope         = module.rg.rg_id
    }
  ]
}

module "key_vault" {
  source = "libre-devops/keyvault/azurerm"

  key_vaults = [
    {
      name                            = "kv-${var.short}-${var.loc}-${var.env}-tst-01"
      rg_name                         = module.rg.rg_name
      location                        = module.rg.rg_location
      tags                            = module.rg.rg_tags
      enabled_for_deployment          = true
      enabled_for_disk_encryption     = true
      enabled_for_template_deployment = true
      enable_rbac_authorization       = true
      purge_protection_enabled        = false
      public_network_access_enabled   = true
      network_acls = {
        default_action             = "Deny"
        bypass                     = "AzureServices"
        ip_rules                   = [chomp(data.http.user_ip.response_body)]
        virtual_network_subnet_ids = [module.network.subnets_ids["subnet1"]]
      }
    }
  ]
}

module "private_endpoint" {
  source = "../../"

  private_endpoints = [
    {
      private_endpoint_name = "pep-${var.short}-${var.loc}-${var.env}-01"
      location              = module.rg.rg_location
      rg_name               = module.rg.rg_name
      subnet_id             = module.network.subnets_ids["subnet1"]
      tags                  = module.rg.rg_tags
      private_service_connection = {
        private_connection_resource_id = module.key_vault.key_vault_ids[0]
        subresource_names              = ["vault"]
      }
    },
  ]
}