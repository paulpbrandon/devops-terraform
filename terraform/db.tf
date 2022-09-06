resource "azurerm_cosmosdb_account" "cosmosdb" {
  name                = "aks-test"
  location            = "ukwest"
  resource_group_name = azurerm_resource_group.rg.name
  offer_type          = "Standard"
  kind                = "MongoDB"

  capabilities {
    name = "mongoEnableDocLevelTTL"
  }

  capabilities {
    name = "EnableMongo"
  }

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }

  public_network_access_enabled = false

  is_virtual_network_filter_enabled = true

  #this should hopefully demonstrate access at the service level, may be able to use private endpoints for more granular control
  virtual_network_rule {
    id = azurerm_subnet.aks.id
  }

}

resource "azurerm_cosmosdb_mongo_database" "checkins" {
  name                = "check-ins"
  resource_group_name = azurerm_cosmosdb_account.cosmosdb.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
}

resource "azurerm_cosmosdb_mongo_collection" "example" {
  name                = "lessonplans"
  resource_group_name = azurerm_cosmosdb_account.cosmosdb.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
  database_name       = azurerm_cosmosdb_mongo_database.checkins.name

  default_ttl_seconds = "-1"
  shard_key           = "uniqueKey"
  throughput          = 400

  index {
    keys   = ["_id"]
    unique = true
  }
}