variable "custom_network_interface_name" {
  type        = string
  description = "The name of your private endpoint NIC"
  default     = null
}

variable "ip_configuration" {
  type        = any
  description = "The ip configuration block"
  default     = null
}

variable "location" {
  description = "The location for this resource to be put in"
  type        = string
}

variable "private_dns_zone_group" {
  type        = any
  description = "The private_dns_zone_group block"
  default     = null
}

variable "private_endpoint_name" {
  type        = string
  description = "The name of the private endpoint"
}

variable "private_service_connection" {
  type        = any
  description = "The private_service_connection block"
  default     = {}
}

variable "rg_name" {
  description = "The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists"
  type        = string
  validation {
    condition     = length(var.rg_name) > 1 && length(var.rg_name) <= 24
    error_message = "Resource group name is not valid."
  }
}

variable "sub_resource_names" {
  type        = map(string)
  description = "The sub resource names of private endpoints found at https://learn.microsoft.com/en-gb/azure/private-link/private-endpoint-overview#private-link-resource, not used, but provided for lookup option"
  default = {
    "Microsoft.Appconfiguration/configurationStores"         = "configurationStores"
    "Microsoft.Automation/automationAccounts"                = "Webhook, DSCAndHybridWorker"
    "Microsoft.AzureCosmosDB/databaseAccounts"               = "SQL, MongoDB, Cassandra, Gremlin, Table"
    "Microsoft.Batch/batchAccounts"                          = "batchAccount, nodeManagement"
    "Microsoft.Cache/Redis"                                  = "redisCache"
    "Microsoft.Cache/redisEnterprise"                        = "redisEnterprise"
    "Microsoft.CognitiveServices/accounts"                   = "account"
    "Microsoft.Compute/diskAccesses"                         = "managed disk"
    "Microsoft.ContainerRegistry/registries"                 = "registry"
    "Microsoft.ContainerService/managedClusters"             = "management"
    "Microsoft.DataFactory/factories"                        = "dataFactory"
    "Microsoft.Kusto/clusters"                               = "cluster"
    "Microsoft.DBforMariaDB/servers"                         = "mariadbServer"
    "Microsoft.DBforMySQL/servers"                           = "mysqlServer"
    "Microsoft.DBforPostgreSQL/servers"                      = "postgresqlServer"
    "Microsoft.Devices/provisioningServices"                 = "iotDps"
    "Microsoft.Devices/IotHubs"                              = "iotHub"
    "Microsoft.IoTCentral/IoTApps"                           = "IoTApps"
    "Microsoft.DigitalTwins/digitalTwinsInstances"           = "API"
    "Microsoft.EventGrid/domains"                            = "domain"
    "Microsoft.EventGrid/topics"                             = "topic"
    "Microsoft.EventHub/namespaces"                          = "namespace"
    "Microsoft.HDInsight/clusters"                           = "cluster"
    "Microsoft.HealthcareApis/services"                      = "fhir"
    "Microsoft.Keyvault/managedHSMs"                         = "HSM"
    "Microsoft.KeyVault/vaults"                              = "vault"
    "Microsoft.MachineLearningServices/workspaces"           = "amlworkspace"
    "Microsoft.Migrate/assessmentProjects"                   = "project"
    "Microsoft.Network/applicationgateways"                  = "application gateway"
    "Microsoft.Network/privateLinkServices"                  = "empty"
    "Microsoft.PowerBI/privateLinkServicesForPowerBI"        = "Power BI"
    "Microsoft.Purview/accounts"                             = "account, portal"
    "Microsoft.RecoveryServices/vaults"                      = "AzureBackup, AzureSiteRecovery"
    "Microsoft.Relay/namespaces"                             = "namespace"
    "Microsoft.Search/searchServices"                        = "searchService"
    "Microsoft.ServiceBus/namespaces"                        = "namespace"
    "Microsoft.SignalRService/SignalR"                       = "signalr"
    "Microsoft.SignalRService/webPubSub"                     = "webpubsub"
    "Microsoft.Sql/servers"                                  = "SQL Server (sqlServer)"
    "Microsoft.Storage/storageAccounts"                      = "blob, blob_secondary, table, table_secondary, queue, queue_secondary, file, file_secondary, web, web_secondary, dfs, dfs_secondary"
    "Microsoft.StorageSync/storageSyncServices"              = "File Sync Service"
    "Microsoft.Synapse/privateLinkHubs"                      = "web"
    "Microsoft.Synapse/workspaces"                           = "Sql, SqlOnDemand, Dev"
    "Microsoft.Web/hostingEnvironments"                      = "hosting environment"
    "Microsoft.Web/sites"                                    = "sites"
    "Microsoft.Web/staticSites"                              = "staticSites"
    "Microsoft.Media/mediaservices"                          = "keydelivery, liveevent, streamingendpoint"
    "Microsoft.Authorization/resourceManagementPrivateLinks" = "ResourceManagement"
    "Microsoft.Databricks/workspaces"                        = "databricks_ui_api, browser_authentication"
    "Microsoft.Insights/privatelinkscopes"                   = "azuremonitor"
  }
}

variable "subnet_id" {
  type        = string
  description = "The ID of the subnet the private endpoint needs to connect"
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}
