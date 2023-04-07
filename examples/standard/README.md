
```hcl
module "rg" {
  source = "registry.terraform.io/libre-devops/rg/azurerm"

  rg_name  = "rg-${var.short}-${var.loc}-${terraform.workspace}-build" // rg-ldo-euw-dev-build
  location = local.location                                            // compares var.loc with the var.regions var to match a long-hand name, in this case, "euw", so "westeurope"
  tags     = local.tags

  #  lock_level = "CanNotDelete" // Do not set this value to skip lock
}

module "network" {
  source = "registry.terraform.io/libre-devops/network/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  vnet_name     = "vnet-${var.short}-${var.loc}-${terraform.workspace}-01" // vnet-ldo-euw-dev-01
  vnet_location = module.network.vnet_location

  address_space = ["10.0.0.0/16"]
  subnet_prefixes = [
    "10.0.0.0/24",
    "10.0.1.0/24",
  ]

  subnet_names = [
    "sn1-${module.network.vnet_name}",
    "sn2-${module.network.vnet_name}",
  ]

  subnet_service_endpoints = {
    "sn1-${module.network.vnet_name}" = ["Microsoft.Storage", "Microsoft.Keyvault", "Microsoft.Sql", "Microsoft.Web", "Microsoft.AzureActiveDirectory"],
    "sn2-${module.network.vnet_name}" = ["Microsoft.Storage", "Microsoft.Keyvault", "Microsoft.Sql", "Microsoft.Web", "Microsoft.AzureActiveDirectory"]
  }
}

# Create a NSG with an explict deny at 4096, since this environment needs 5 NSGs, count is set to 5
module "nsg" {
  source   = "registry.terraform.io/libre-devops/nsg/azurerm"
  count    = 2
  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  nsg_name  = "nsg-${var.short}-${var.loc}-${terraform.workspace}-${format("%02d", count.index + 1)}" // nsg-ldo-euw-dev-01 - the format("%02d") applies number padding e.g 1 = 01, 2 = 02
  subnet_id = element(values(module.network.subnets_ids), count.index)
}

resource "azurerm_network_security_rule" "vnet_inbound" {
  count = 2 # can't use length() of subnet ids as not known till apply

  name                        = "AllowVnetInbound"
  priority                    = "149"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = module.rg.rg_name
  network_security_group_name = module.nsg[count.index].nsg_name
}


resource "azurerm_network_security_rule" "bastion_inbound" {
  count = 2 # can't use length() of subnet ids as not known till apply

  name                        = "AllowSSHRDPInbound"
  priority                    = "150"
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["22", "3389"]
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = module.rg.rg_name
  network_security_group_name = module.nsg[count.index].nsg_name
}

module "law" {
  source = "registry.terraform.io/libre-devops/log-analytics-workspace/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  create_new_workspace       = true
  law_name                   = "law-${var.short}-${var.loc}-${terraform.workspace}-01"
  law_sku                    = "PerGB2018"
  retention_in_days          = "30"
  daily_quota_gb             = "0.5"
  internet_ingestion_enabled = true
  internet_query_enabled     = true
}

// This module does not consider for CMKs and allows the users to manually set bypasses
#checkov:skip=CKV2_AZURE_1:CMKs are not considered in this module
#checkov:skip=CKV2_AZURE_18:CMKs are not considered in this module
#checkov:skip=CKV_AZURE_33:Storage logging is not configured by default in this module
#tfsec:ignore:azure-storage-queue-services-logging-enabled tfsec:ignore:azure-storage-allow-microsoft-service-bypass #tfsec:ignore:azure-storage-default-action-deny
module "sa" {
  source = "registry.terraform.io/libre-devops/storage-account/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  storage_account_name            = "st${var.short}${var.loc}${terraform.workspace}01"
  access_tier                     = "Hot"
  identity_type                   = "SystemAssigned"
  allow_nested_items_to_be_public = true

  storage_account_properties = {

    // Set this block to enable network rules
    network_rules = {
      default_action = "Allow"
    }

    blob_properties = {
      versioning_enabled       = false
      change_feed_enabled      = false
      default_service_version  = "2020-06-12"
      last_access_time_enabled = false

      deletion_retention_policies = {
        days = 10
      }

      container_delete_retention_policy = {
        days = 10
      }
    }

    routing = {
      publish_internet_endpoints  = false
      publish_microsoft_endpoints = true
      choice                      = "MicrosoftRouting"
    }
  }
}

module "plan" {
  source = "registry.terraform.io/libre-devops/service-plan/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  app_service_plan_name          = "asp-${var.short}-${var.loc}-${terraform.workspace}-01"
  add_to_app_service_environment = false

  os_type  = "Linux"
  sku_name = "P1v3"
}

#checkov:skip=CKV2_AZURE_145:TLS 1.2 is allegedly the latest supported as per hashicorp docs
module "fnc_app" {
  source = "libre-devops/linux-function-app/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  app_name        = "fnc-${var.short}-${var.loc}-${terraform.workspace}-01"
  service_plan_id = module.plan.service_plan_id

  connect_app_insights_to_law_workspace = true
  enable_app_insights                   = true
  workspace_id                          = module.law.law_id
  app_insights_name                     = "appi-${var.short}-${var.loc}-${terraform.workspace}-01"
  app_insights_type                     = "web"

  #  function_app_vnet_integration_enabled = true
  #  function_app_vnet_integration_subnet_id = element(values(module.network.subnets_ids), 0)


  app_settings = {
    ARM_SUBSCRIPTION_ID = data.azurerm_client_config.current_creds.subscription_id
    ARM_TENANT_ID       = data.azurerm_client_config.current_creds.tenant_id
    FUNCTION_APP_NAME   = "fnc-${var.short}-${var.loc}-${terraform.workspace}-01"
    RESOURCE_GROUP_NAME = module.rg.rg_name
  }

  storage_account_name          = module.sa.sa_name
  storage_account_access_key    = module.sa.sa_primary_access_key
  storage_uses_managed_identity = true

  identity_type = "SystemAssigned"

  functions_extension_version = "~4"

  settings = {
    site_config = {
      minimum_tls_version = "1.2"
      http2_enabled       = true

      application_stack = {
        python_version = 3.9
      }
    }

    auth_settings = {
      enabled                       = false
      runtime_version               = "~1"
      unauthenticated_client_action = "AllowAnonymous"
    }
  }
}

module "private_endpoint" {
  source = "../../"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  private_endpoint_name = "pep-${var.short}-${var.loc}-${terraform.workspace}-01"
  subnet_id             = element(values(module.network.subnets_ids), 1)

  private_service_connection = {
    name                           = "pvsvccon-${var.short}-${var.loc}-${terraform.workspace}-01"
    is_manual_connection           = false
    private_connection_resource_id = module.fnc_app.fnc_app_id
    subresource_names              = ["sites"]
  }
}
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_fnc_app"></a> [fnc\_app](#module\_fnc\_app) | libre-devops/linux-function-app/azurerm | n/a |
| <a name="module_law"></a> [law](#module\_law) | registry.terraform.io/libre-devops/log-analytics-workspace/azurerm | n/a |
| <a name="module_network"></a> [network](#module\_network) | registry.terraform.io/libre-devops/network/azurerm | n/a |
| <a name="module_nsg"></a> [nsg](#module\_nsg) | registry.terraform.io/libre-devops/nsg/azurerm | n/a |
| <a name="module_plan"></a> [plan](#module\_plan) | registry.terraform.io/libre-devops/service-plan/azurerm | n/a |
| <a name="module_private_endpoint"></a> [private\_endpoint](#module\_private\_endpoint) | ../../ | n/a |
| <a name="module_rg"></a> [rg](#module\_rg) | registry.terraform.io/libre-devops/rg/azurerm | n/a |
| <a name="module_sa"></a> [sa](#module\_sa) | registry.terraform.io/libre-devops/storage-account/azurerm | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_network_security_rule.bastion_inbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_network_security_rule.vnet_inbound](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_client_config.current_creds](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_key_vault.mgmt_kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault) | data source |
| [azurerm_key_vault_secret.mgmt_local_admin_pwd](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret) | data source |
| [azurerm_resource_group.mgmt_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_ssh_public_key.mgmt_ssh_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/ssh_public_key) | data source |
| [azurerm_user_assigned_identity.mgmt_user_assigned_id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/user_assigned_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_Regions"></a> [Regions](#input\_Regions) | Converts shorthand name to longhand name via lookup on map list | `map(string)` | <pre>{<br>  "eus": "East US",<br>  "euw": "West Europe",<br>  "uks": "UK South",<br>  "ukw": "UK West"<br>}</pre> | no |
| <a name="input_env"></a> [env](#input\_env) | This is passed as an environment variable, it is for the shorthand environment tag for resource.  For example, production = prod | `string` | `"dev"` | no |
| <a name="input_loc"></a> [loc](#input\_loc) | The shorthand name of the Azure location, for example, for UK South, use uks.  For UK West, use ukw. Normally passed as TF\_VAR in pipeline | `string` | `"euw"` | no |
| <a name="input_short"></a> [short](#input\_short) | This is passed as an environment variable, it is for a shorthand name for the environment, for example hello-world = hw | `string` | `"ldo"` | no |

## Outputs

No outputs.
