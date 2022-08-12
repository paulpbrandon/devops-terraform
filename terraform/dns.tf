resource "azurerm_public_ip" "ingress-ip" {
  name                = "ingressIP"
  resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  ip_version          = "IPv4"
  sku                 = "Standard"
}

resource "azurerm_dns_zone" "cluster-domain" {
  name                = var.cluster_domain
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_dns_a_record" "argo" {
  name                = "argo"
  zone_name           = azurerm_dns_zone.cluster-domain.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 3600
  target_resource_id  = azurerm_public_ip.ingress-ip.id
}

resource "azurerm_dns_a_record" "drone" {
  name                = "drone"
  zone_name           = azurerm_dns_zone.cluster-domain.name
  resource_group_name = azurerm_resource_group.rg.name
  ttl                 = 3600
  target_resource_id  = azurerm_public_ip.ingress-ip.id
}