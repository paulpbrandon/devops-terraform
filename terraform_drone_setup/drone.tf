data "azurerm_container_registry" "acr" {
  name                = "paulbnimbleregistry"
  resource_group_name = "pauls-demo-group"
}

data "azuread_client_config" "current" {}

resource "azuread_application" "drone-acr" {
  display_name = "drone-acrpush"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "drone-acr" {
  application_id = azuread_application.drone-acr.application_id
  owners         = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "drone-acr" {
  service_principal_id = azuread_service_principal.drone-acr.id
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