```hcl
resource "azurerm_private_endpoint" "this" {
  for_each = { for idx, pe in var.private_endpoints : idx => pe }

  name                          = each.value.private_endpoint_name
  location                      = each.value.location
  resource_group_name           = each.value.rg_name
  subnet_id                     = each.value.subnet_id
  custom_network_interface_name = each.value.custom_network_interface_name
  tags                          = each.value.tags

  dynamic "private_service_connection" {
    for_each = each.value.private_service_connection != null ? [each.value.private_service_connection] : []
    content {
      name                              = lookup(private_service_connection.value, "name", null) == null ? "pvsvccon-${each.value.private_endpoint_name}" : null
      is_manual_connection              = lookup(private_service_connection.value, "is_manual_connection", true)
      private_connection_resource_id    = lookup(private_service_connection.value, "private_connection_resource_id", null)
      private_connection_resource_alias = lookup(private_service_connection.value, "private_connection_resource_alias", null)
      subresource_names                 = lookup(private_service_connection.value, "subresource_names", [])
      request_message                   = private_service_connection.value.is_manual_connection && lookup(private_service_connection.value, "request_message", null) == null ? "This is a manual private endpoint connection for ${each.value.private_endpoint_name}" : lookup(private_service_connection.value, "request_message", null)
    }
  }

  dynamic "private_dns_zone_group" {
    for_each = each.value.private_dns_zone_group != null ? [each.value.private_dns_zone_group] : []
    content {
      name                 = lookup(private_dns_zone_group.value, "name", null)
      private_dns_zone_ids = lookup(private_dns_zone_group.value, "private_dns_zone_ids", [])
    }
  }

  dynamic "ip_configuration" {
    for_each = each.value.ip_configuration != null ? [each.value.ip_configuration] : []
    content {
      name               = lookup(ip_configuration.value, "name", null)
      private_ip_address = lookup(ip_configuration.value, "private_ip_address", null)
      subresource_name   = lookup(ip_configuration.value, "subresource_name", null)
      member_name        = lookup(ip_configuration.value, "member_name", null)
    }
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

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints) | The databricks workspaces to create | <pre>list(object({<br/>    private_endpoint_name         = string<br/>    location                      = optional(string, "uksouth")<br/>    rg_name                       = string<br/>    subnet_id                     = string<br/>    custom_network_interface_name = optional(string, null)<br/>    tags                          = optional(map(string), {})<br/>    private_service_connection = optional(object({<br/>      name                              = optional(string)<br/>      is_manual_connection              = optional(bool, true)<br/>      private_connection_resource_id    = optional(string)<br/>      private_connection_resource_alias = optional(string)<br/>      subresource_names                 = optional(list(string))<br/>      request_message                   = optional(string)<br/>    }))<br/>    private_dns_zone_group = optional(object({<br/>      name                 = optional(string)<br/>      private_dns_zone_ids = optional(list(string))<br/>    }))<br/>    ip_configuration = optional(object({<br/>      name               = optional(string)<br/>      private_ip_address = optional(string)<br/>      subresource_name   = optional(string)<br/>      member_name        = optional(string)<br/>    }))<br/>  }))</pre> | n/a | yes |
| <a name="input_subresource_names"></a> [subresource\_names](#input\_subresource\_names) | The sub resource names of private endpoints found at https://learn.microsoft.com/en-gb/azure/private-link/private-endpoint-overview#private-link-resource, not used, but provided for lookup option | `map(string)` | <pre>{<br/>  "Microsoft.Appconfiguration/configurationStores": "configurationStores",<br/>  "Microsoft.Attestation/attestationProviders": "standard",<br/>  "Microsoft.Authorization/resourceManagementPrivateLinks": "ResourceManagement",<br/>  "Microsoft.Automation/automationAccounts": "Webhook, DSCAndHybridWorker",<br/>  "Microsoft.AzureCosmosDB/databaseAccounts": "SQL, MongoDB, Cassandra, Gremlin, Table",<br/>  "Microsoft.Batch/batchAccounts": "batchAccount, nodeManagement",<br/>  "Microsoft.Cache/Redis": "redisCache",<br/>  "Microsoft.Cache/redisEnterprise": "redisEnterprise",<br/>  "Microsoft.CognitiveServices/accounts": "account",<br/>  "Microsoft.Compute/diskAccesses": "managed disk",<br/>  "Microsoft.ContainerRegistry/registries": "registry",<br/>  "Microsoft.ContainerService/managedClusters": "management",<br/>  "Microsoft.DBforMariaDB/servers": "mariadbServer",<br/>  "Microsoft.DBforMySQL/flexibleServers": "mysqlServer",<br/>  "Microsoft.DBforMySQL/servers": "mysqlServer",<br/>  "Microsoft.DBforPostgreSQL/flexibleServers": "postgresqlServer",<br/>  "Microsoft.DBforPostgreSQL/serverGroupsv2": "coordinator",<br/>  "Microsoft.DBforPostgreSQL/servers": "postgresqlServer",<br/>  "Microsoft.DataFactory/factories": "dataFactory",<br/>  "Microsoft.Databricks/workspaces": "databricks_ui_api, browser_authentication",<br/>  "Microsoft.DesktopVirtualization/hostpools": "connection",<br/>  "Microsoft.DesktopVirtualization/workspaces": "feed",<br/>  "Microsoft.DeviceUpdate/accounts": "DeviceUpdate",<br/>  "Microsoft.Devices/IotHubs": "iotHub",<br/>  "Microsoft.Devices/provisioningServices": "iotDps",<br/>  "Microsoft.DigitalTwins/digitalTwinsInstances": "API",<br/>  "Microsoft.DocumentDb/mongoClusters": "mongoCluster",<br/>  "Microsoft.EventGrid/domains": "domain",<br/>  "Microsoft.EventGrid/topics": "topic",<br/>  "Microsoft.EventHub/namespaces": "namespace",<br/>  "Microsoft.HDInsight/clusters": "cluster",<br/>  "Microsoft.HealthcareApis/services": "fhir",<br/>  "Microsoft.Insights/privatelinkscopes": "azuremonitor",<br/>  "Microsoft.IoTCentral/IoTApps": "IoTApps",<br/>  "Microsoft.KeyVault/vaults": "vault",<br/>  "Microsoft.Keyvault/managedHSMs": "HSM",<br/>  "Microsoft.Kusto/clusters": "cluster",<br/>  "Microsoft.MachineLearningServices/registries": "amlregistry",<br/>  "Microsoft.MachineLearningServices/workspaces": "amlworkspace",<br/>  "Microsoft.Media/mediaservices": "keydelivery, liveevent, streamingendpoint",<br/>  "Microsoft.Migrate/assessmentProjects": "project",<br/>  "Microsoft.Network/applicationgateways": "application gateway",<br/>  "Microsoft.Network/privateLinkServices": "empty",<br/>  "Microsoft.PowerBI/privateLinkServicesForPowerBI": "Power BI",<br/>  "Microsoft.Purview/accounts": "account, portal",<br/>  "Microsoft.RecoveryServices/vaults": "AzureBackup, AzureSiteRecovery",<br/>  "Microsoft.Relay/namespaces": "namespace",<br/>  "Microsoft.Search/searchServices": "searchService",<br/>  "Microsoft.ServiceBus/namespaces": "namespace",<br/>  "Microsoft.SignalRService/SignalR": "signalr",<br/>  "Microsoft.SignalRService/webPubSub": "webpubsub",<br/>  "Microsoft.Sql/managedInstances": "managedInstance",<br/>  "Microsoft.Sql/servers": "sqlServer",<br/>  "Microsoft.Storage/storageAccounts": "blob, blob_secondary, table, table_secondary, queue, queue_secondary, file, file_secondary, web, web_secondary, dfs, dfs_secondary",<br/>  "Microsoft.StorageSync/storageSyncServices": "File Sync Service",<br/>  "Microsoft.Synapse/privateLinkHubs": "web",<br/>  "Microsoft.Synapse/workspaces": "Sql, SqlOnDemand, Dev",<br/>  "Microsoft.Web/hostingEnvironments": "hosting environment",<br/>  "Microsoft.Web/sites": "sites",<br/>  "Microsoft.Web/staticSites": "staticSites"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_endpoint_custom_network_interface_names"></a> [private\_endpoint\_custom\_network\_interface\_names](#output\_private\_endpoint\_custom\_network\_interface\_names) | The custom network interface names of the created Azure Private Endpoints. |
| <a name="output_private_endpoint_ids"></a> [private\_endpoint\_ids](#output\_private\_endpoint\_ids) | The IDs of the created Azure Private Endpoints. |
| <a name="output_private_endpoint_locations"></a> [private\_endpoint\_locations](#output\_private\_endpoint\_locations) | The locations of the created Azure Private Endpoints. |
| <a name="output_private_endpoint_names"></a> [private\_endpoint\_names](#output\_private\_endpoint\_names) | The names of the created Azure Private Endpoints. |
| <a name="output_private_endpoint_rg_names"></a> [private\_endpoint\_rg\_names](#output\_private\_endpoint\_rg\_names) | The resource group names of the created Azure Private Endpoints. |
| <a name="output_private_endpoint_subnet_ids"></a> [private\_endpoint\_subnet\_ids](#output\_private\_endpoint\_subnet\_ids) | The subnet IDs of the created Azure Private Endpoints. |
| <a name="output_private_endpoint_tags"></a> [private\_endpoint\_tags](#output\_private\_endpoint\_tags) | The tags associated with the created Azure Private Endpoints. |
