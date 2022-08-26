resource "azurerm_virtual_network" "aks" {
  name                = "aks-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]
}
resource "azurerm_subnet" "aks" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_resource_group.rg.location
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = ["Microsoft.AzureCosmosDB"]
}