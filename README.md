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
| [azurerm_private_endpoint.endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_network_interface_name"></a> [custom\_network\_interface\_name](#input\_custom\_network\_interface\_name) | The name of your private endpoint NIC | `string` | `null` | no |
| <a name="input_ip_configuration"></a> [ip\_configuration](#input\_ip\_configuration) | The ip configuration block | `any` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location for this resource to be put in | `string` | n/a | yes |
| <a name="input_private_dns_zone_group"></a> [private\_dns\_zone\_group](#input\_private\_dns\_zone\_group) | The private\_dns\_zone\_group block | `any` | `null` | no |
| <a name="input_private_endpoint_name"></a> [private\_endpoint\_name](#input\_private\_endpoint\_name) | The name of the private endpoint | `string` | n/a | yes |
| <a name="input_private_service_connection"></a> [private\_service\_connection](#input\_private\_service\_connection) | The private\_service\_connection block | `any` | `{}` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists | `string` | n/a | yes |
| <a name="input_sub_resource_names"></a> [sub\_resource\_names](#input\_sub\_resource\_names) | The sub resource names of private endpoints found at https://learn.microsoft.com/en-gb/azure/private-link/private-endpoint-overview#private-link-resource, not used, but provided for lookup option | `map(string)` | <pre>{<br>  "Microsoft.Appconfiguration/configurationStores": "configurationStores",<br>  "Microsoft.Authorization/resourceManagementPrivateLinks": "ResourceManagement",<br>  "Microsoft.Automation/automationAccounts": "Webhook, DSCAndHybridWorker",<br>  "Microsoft.AzureCosmosDB/databaseAccounts": "SQL, MongoDB, Cassandra, Gremlin, Table",<br>  "Microsoft.Batch/batchAccounts": "batchAccount, nodeManagement",<br>  "Microsoft.Cache/Redis": "redisCache",<br>  "Microsoft.Cache/redisEnterprise": "redisEnterprise",<br>  "Microsoft.CognitiveServices/accounts": "account",<br>  "Microsoft.Compute/diskAccesses": "managed disk",<br>  "Microsoft.ContainerRegistry/registries": "registry",<br>  "Microsoft.ContainerService/managedClusters": "management",<br>  "Microsoft.DBforMariaDB/servers": "mariadbServer",<br>  "Microsoft.DBforMySQL/servers": "mysqlServer",<br>  "Microsoft.DBforPostgreSQL/servers": "postgresqlServer",<br>  "Microsoft.DataFactory/factories": "dataFactory",<br>  "Microsoft.Databricks/workspaces": "databricks_ui_api, browser_authentication",<br>  "Microsoft.Devices/IotHubs": "iotHub",<br>  "Microsoft.Devices/provisioningServices": "iotDps",<br>  "Microsoft.DigitalTwins/digitalTwinsInstances": "API",<br>  "Microsoft.EventGrid/domains": "domain",<br>  "Microsoft.EventGrid/topics": "topic",<br>  "Microsoft.EventHub/namespaces": "namespace",<br>  "Microsoft.HDInsight/clusters": "cluster",<br>  "Microsoft.HealthcareApis/services": "fhir",<br>  "Microsoft.Insights/privatelinkscopes": "azuremonitor",<br>  "Microsoft.IoTCentral/IoTApps": "IoTApps",<br>  "Microsoft.KeyVault/vaults": "vault",<br>  "Microsoft.Keyvault/managedHSMs": "HSM",<br>  "Microsoft.Kusto/clusters": "cluster",<br>  "Microsoft.MachineLearningServices/workspaces": "amlworkspace",<br>  "Microsoft.Media/mediaservices": "keydelivery, liveevent, streamingendpoint",<br>  "Microsoft.Migrate/assessmentProjects": "project",<br>  "Microsoft.Network/applicationgateways": "application gateway",<br>  "Microsoft.Network/privateLinkServices": "empty",<br>  "Microsoft.PowerBI/privateLinkServicesForPowerBI": "Power BI",<br>  "Microsoft.Purview/accounts": "account, portal",<br>  "Microsoft.RecoveryServices/vaults": "AzureBackup, AzureSiteRecovery",<br>  "Microsoft.Relay/namespaces": "namespace",<br>  "Microsoft.Search/searchServices": "searchService",<br>  "Microsoft.ServiceBus/namespaces": "namespace",<br>  "Microsoft.SignalRService/SignalR": "signalr",<br>  "Microsoft.SignalRService/webPubSub": "webpubsub",<br>  "Microsoft.Sql/servers": "sqlServer",<br>  "Microsoft.Storage/storageAccounts": "blob, blob_secondary, table, table_secondary, queue, queue_secondary, file, file_secondary, web, web_secondary, dfs, dfs_secondary",<br>  "Microsoft.StorageSync/storageSyncServices": "File Sync Service",<br>  "Microsoft.Synapse/privateLinkHubs": "web",<br>  "Microsoft.Synapse/workspaces": "Sql, SqlOnDemand, Dev",<br>  "Microsoft.Web/hostingEnvironments": "hosting environment",<br>  "Microsoft.Web/sites": "sites",<br>  "Microsoft.Web/staticSites": "staticSites"<br>}</pre> | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The ID of the subnet the private endpoint needs to connect | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use on the resources that are deployed with this module. | `map(string)` | <pre>{<br>  "source": "terraform"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint_custom_dns_configs"></a> [endpoint\_custom\_dns\_configs](#output\_endpoint\_custom\_dns\_configs) | The custom dns configs block |
| <a name="output_endpoint_id"></a> [endpoint\_id](#output\_endpoint\_id) | The ID of the private endpoint |
| <a name="output_endpoint_ip_configuration"></a> [endpoint\_ip\_configuration](#output\_endpoint\_ip\_configuration) | The ip configuration block |
| <a name="output_endpoint_name"></a> [endpoint\_name](#output\_endpoint\_name) | The name of the storage account |
| <a name="output_endpoint_network_interface"></a> [endpoint\_network\_interface](#output\_endpoint\_network\_interface) | The network interface block |
| <a name="output_endpoint_private_dns_zone_configs"></a> [endpoint\_private\_dns\_zone\_configs](#output\_endpoint\_private\_dns\_zone\_configs) | The private dns zone configs |
