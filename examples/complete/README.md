<!--
  Header for the complete example README. Edit this file, then run `just docs`
  (or ./Sort-LdoTerraform.ps1 -IncludeExamples) to regenerate the section between the markers.
  The example's main.tf is embedded into the README automatically (see .terraform-docs.yml).
-->
<div align="center">
  <a href="https://libredevops.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://libredevops.org/assets/libre-devops-white.png">
      <img alt="Libre DevOps" src="https://libredevops.org/assets/libre-devops-black.png" width="200">
    </picture>
  </a>
</div>

# Complete example

Exercises the fuller surface of this module. The environment comes from the Terraform workspace
(`terraform.workspace`), not a variable. Run it with `just e2e complete`, which applies the stack
then always destroys it.

[![Terraform Registry](https://img.shields.io/badge/registry-libre--devops-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/namespaces/libre-devops)

<!-- BEGIN_TF_DOCS -->
## Example configuration

```hcl
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
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0, < 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_network"></a> [network](#module\_network) | libre-devops/network/azurerm | ~> 4.0 |
| <a name="module_private_endpoint"></a> [private\_endpoint](#module\_private\_endpoint) | ../../ | n/a |
| <a name="module_rg"></a> [rg](#module\_rg) | libre-devops/rg/azurerm | ~> 4.0 |
| <a name="module_storage"></a> [storage](#module\_storage) | libre-devops/storage-account/azurerm | ~> 4.0 |
| <a name="module_tags"></a> [tags](#module\_tags) | libre-devops/tags/azurerm | ~> 4.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_private_dns_zone.blob](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deployed_branch"></a> [deployed\_branch](#input\_deployed\_branch) | Git branch the deployment came from. Auto-filled in CI from TF\_VAR\_deployed\_branch. | `string` | `""` | no |
| <a name="input_deployed_repo"></a> [deployed\_repo](#input\_deployed\_repo) | Repository URL the deployment came from. Auto-filled in CI from TF\_VAR\_deployed\_repo. | `string` | `""` | no |
| <a name="input_loc"></a> [loc](#input\_loc) | Outfix: short Azure region code used in resource names (for example uks). | `string` | `"uks"` | no |
| <a name="input_regions"></a> [regions](#input\_regions) | Map of short region codes to Azure region slugs. | `map(string)` | <pre>{<br/>  "eus": "eastus",<br/>  "euw": "westeurope",<br/>  "uks": "uksouth",<br/>  "ukw": "ukwest"<br/>}</pre> | no |
| <a name="input_short"></a> [short](#input\_short) | Infix: short product code used in resource names. | `string` | `"ldo"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_application_security_group_ids"></a> [application\_security\_group\_ids](#output\_application\_security\_group\_ids) | The application security group ids created for the endpoints. |
| <a name="output_private_endpoint_ids"></a> [private\_endpoint\_ids](#output\_private\_endpoint\_ids) | Map of endpoint key to private endpoint id. |
| <a name="output_private_endpoint_names"></a> [private\_endpoint\_names](#output\_private\_endpoint\_names) | Map of endpoint key to the auto-derived private endpoint name. |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags applied to the resources. |
<!-- END_TF_DOCS -->
