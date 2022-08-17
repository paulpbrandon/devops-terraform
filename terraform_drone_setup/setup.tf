data "azurerm_resource_group" "rg" {
  name     = "pauls-demo-group"
}

data "azurerm_container_registry" "acr" {
  name                = "paulbnimbleregistry"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_kubernetes_cluster" "aks" {
  name = "pauls-demo-aks-cluster"
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "kubectl_path_documents" "sealed-secrets" {
  pattern = "../secrets/*.yaml"
}

resource "azurerm_role_assignment" "drone-acrpush" {
  principal_id                     = azuread_service_principal.drone-acr.id
  role_definition_name             = "AcrPush"
  scope                            = data.azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}

resource "drone_orgsecret" "docker-user" {
  namespace = var.github_org
  name      = "docker_user"
  value     = azuread_application.drone-acr.application_id
}

resource "drone_orgsecret" "docker-pass" {
  namespace = var.github_org
  name      = "docker_pass"
  value     = azuread_service_principal_password.drone-acr.value
}

resource "drone_template" "node-baseline" {
  namespace = var.github_org
  name      = "node-baseline.yaml"
  data      = file("../templates/node-baseline.yaml")
}

resource "kubectl_manifest" "sealed-secrets" {
  for_each  = toset(data.kubectl_path_documents.sealed-secrets.documents)
  yaml_body = each.value
  override_namespace = "argocd"
}
