<!--
  Keep the title and badges OUTSIDE the centered <div>: the Terraform Registry's markdown renderer
  does not parse markdown inside an HTML block, so a # heading or [![badge]] in the div renders as
  literal text on the registry. Only the logo (HTML) goes in the div.
-->
<div align="center">
  <a href="https://libredevops.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://libredevops.org/assets/libre-devops-white.png">
      <img alt="Libre DevOps" src="https://libredevops.org/assets/libre-devops-black.png" width="300">
    </picture>
  </a>
</div>

# Terraform Azure Private Endpoint

Private endpoints with auto-derived names and auto-resolved private DNS zone groups.

[![CI](https://github.com/libre-devops/terraform-azurerm-private-endpoint/actions/workflows/ci.yml/badge.svg)](https://github.com/libre-devops/terraform-azurerm-private-endpoint/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/libre-devops/terraform-azurerm-private-endpoint?sort=semver&label=release)](https://github.com/libre-devops/terraform-azurerm-private-endpoint/releases/latest)
[![Terraform Registry](https://img.shields.io/badge/registry-libre--devops-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/namespaces/libre-devops)
[![License](https://img.shields.io/github/license/libre-devops/terraform-azurerm-private-endpoint)](./LICENSE)

---

## Overview

Private endpoints keyed by a logical name, with two conveniences that keep the config terse:

- **Auto-naming** - the target resource name is parsed from its connection id, so the endpoint defaults
  to `pep-<subresource>-<target>` and its NIC to `nic-pep-<subresource>-<target>` (both overridable).
- **Auto DNS zone group** - set `auto_dns_zone_group = true` and the module resolves the endpoint's
  private DNS zone from the module-level `private_dns_zone_ids` map (subresource -> zone id, typically
  your hub's private DNS zones), so you do not repeat zone ids per endpoint. An explicit
  `private_dns_zone_group` always wins.

Optionally create an application security group per endpoint and associate it. The resource group is
passed by id and parsed. Pairs naturally with the `keyvault`, `storage-account`, and `network` modules
to lock a PaaS resource down to a subnet.

## Usage

```hcl
module "private_endpoint" {
  source  = "libre-devops/private-endpoint/azurerm"
  version = "~> 4.0"

  resource_group_id = module.rg.ids["rg-ldo-uks-prd-001"]
  location          = "uksouth"
  tags              = module.tags.tags

  # subresource -> hub private DNS zone id (drives auto_dns_zone_group).
  private_dns_zone_ids = { vault = data.azurerm_private_dns_zone.kv.id }

  private_endpoints = {
    "kv" = {
      subnet_id           = module.network.subnet_ids["snet-pe-vnet-ldo-uks-prd-001"]
      auto_dns_zone_group = true
      private_service_connection = {
        private_connection_resource_id = module.keyvault.ids["kv-ldo-uks-prd-001"]
        subresource_names              = ["vault"]
      }
    }
  }
}
```

## Examples

- [`examples/minimal`](./examples/minimal) - a private endpoint to a storage account's blob service with
  an explicit DNS zone group.
- [`examples/complete`](./examples/complete) - a private endpoint that auto-resolves its DNS zone group
  from the subresource map and creates an associated application security group.

## Developing

Local work needs **PowerShell 7+** and **[`just`](https://github.com/casey/just)**, because the recipes
wrap the [LibreDevOpsHelpers](https://www.powershellgallery.com/packages/LibreDevOpsHelpers)
PowerShell module (the same engine the `libre-devops/terraform-azure` action runs in CI). Install
just with `brew install just`, or `uv tool add rust-just` then `uv run just <recipe>`.

Run `just` to list recipes: `just update-ldo-pwsh` (install or force-update LibreDevOpsHelpers from
PSGallery), `just validate`, `just scan` (Trivy only), `just pwsh-analyze` (PSScriptAnalyzer only),
`just plan`, `just apply`, `just destroy`, `just e2e`, `just test`, and `just docs` (the
plan/apply/destroy recipes mirror the action, including the storage firewall dance; `just e2e`
applies an example then always destroys it, defaulting to `minimal`, so nothing is left running).
Releasing is also `just`:
`just increment-release [patch|minor|major]` bumps, tags, and publishes a GitHub release, and the
Terraform Registry picks up the tag.

## Security scan exceptions

This module is scanned with [Trivy](https://github.com/aquasecurity/trivy); HIGH and CRITICAL
findings fail the build. Any waiver is a deliberate, reviewed decision, never a way to quiet a
finding that should be fixed. Waivers live in [`.trivyignore.yaml`](./.trivyignore.yaml) (the
machine-applied source of truth, passed to Trivy with `--ignorefile`) and are mirrored in a table
here so the reason is auditable.

There are currently **no exceptions**: the module and its examples scan clean. A private endpoint
carries no security posture of its own (it is a network attachment), so there is nothing to waive.

To add an exception: add an entry to `.trivyignore.yaml` (`id`, optional `paths` to scope it, and a
`statement` recording why), then add a matching row here recording the reason. Both the file and
the table are reviewed in the pull request.

## Reference

The Requirements, Providers, Inputs, Outputs, and Resources below are generated by `terraform-docs`.
