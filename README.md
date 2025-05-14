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
      name                              = private_service_connection.value.name == null ? "pvsvccon-${each.value.private_endpoint_name}" : null
      is_manual_connection              = private_service_connection.value.is_manual_connection
      private_connection_resource_id    = private_service_connection.value.private_connection_resource_id
      private_connection_resource_alias = private_service_connection.value.private_connection_resource_alias
      subresource_names                 = private_service_connection.value.subresource_names
      request_message                   = private_service_connection.value.is_manual_connection == null && private_service_connection.value.request_message == null ? "This is a manual private endpoint connection for ${each.value.private_endpoint_name}" : private_service_connection.value.request_message
    }
  }

  dynamic "private_dns_zone_group" {
    for_each = each.value.private_dns_zone_group != null ? [each.value.private_dns_zone_group] : []
    content {
      name                 = private_dns_zone_group.value.name
      private_dns_zone_ids = private_dns_zone_group.value.private_dns_zone_ids
    }
  }

  dynamic "ip_configuration" {
    for_each = each.value.ip_configuration != null ? [each.value.ip_configuration] : []
    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      subresource_name   = ip_configuration.value.subresource_name
      member_name        = ip_configuration.value.member_name
    }
  }
}

resource "azurerm_application_security_group" "pep_asg" {
  for_each = { for idx, pe in var.private_endpoints : idx => pe if pe.create_asg == true }

  name                = each.value.asg_name != null ? each.value.asg_name : "asg-${each.value.private_endpoint_name}"
  location            = azurerm_private_endpoint.this[each.key].location
  resource_group_name = azurerm_private_endpoint.this[each.key].resource_group_name
  tags                = azurerm_private_endpoint.this[each.key].tags
}

resource "azurerm_private_endpoint_application_security_group_association" "pep_asg_association" {
  for_each                      = { for idx, pe in var.private_endpoints : idx => pe if pe.create_asg == true && pe.create_asg_association == true }
  private_endpoint_id           = azurerm_private_endpoint.this[each.key].id
  application_security_group_id = azurerm_application_security_group.pep_asg[each.key].id
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
| [azurerm_application_security_group.pep_asg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/application_security_group) | resource |
| [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_private_endpoint_application_security_group_association.pep_asg_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint_application_security_group_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_private_endpoints"></a> [private\_endpoints](#input\_private\_endpoints) | The databricks workspaces to create | <pre>list(object({<br/>    private_endpoint_name         = string<br/>    location                      = optional(string, "uksouth")<br/>    rg_name                       = string<br/>    subnet_id                     = string<br/>    custom_network_interface_name = optional(string, null)<br/>    tags                          = optional(map(string), {})<br/>    create_asg                    = optional(bool, false)<br/>    asg_name                      = optional(string)<br/>    create_asg_association        = optional(bool, false)<br/><br/>    private_service_connection = optional(object({<br/>      name                              = optional(string)<br/>      is_manual_connection              = optional(bool, false)<br/>      private_connection_resource_id    = optional(string)<br/>      private_connection_resource_alias = optional(string)<br/>      subresource_names                 = optional(list(string))<br/>      request_message                   = optional(string)<br/>    }))<br/>    private_dns_zone_group = optional(object({<br/>      name                 = optional(string)<br/>      private_dns_zone_ids = optional(list(string))<br/>    }))<br/>    ip_configuration = optional(object({<br/>      name               = optional(string)<br/>      private_ip_address = optional(string)<br/>      subresource_name   = optional(string)<br/>      member_name        = optional(string)<br/>    }))<br/>  }))</pre> | n/a | yes |
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
