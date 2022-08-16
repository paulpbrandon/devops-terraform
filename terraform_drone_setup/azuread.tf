data "azuread_client_config" "current" {}

resource "azuread_application" "drone-acr" {
  display_name = "drone-acrpush"
  sign_in_audience = "AzureADMyOrg"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "drone-acr" {
  application_id = azuread_application.drone-acr.application_id
  owners         = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "drone-acr" {
  service_principal_id = azuread_service_principal.drone-acr.id
}

resource "azuread_application" "oauth2-proxy" {
  display_name = "oauth2-proxy"
  owners       = [data.azuread_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"
  group_membership_claims = ["SecurityGroup"]

  web {
    logout_url    = "https://hw-prod.paulpbrandon.uk/oauth2/sign_out" #could do with a generic ingress to the proxy for sign out if multiple apps use this
    redirect_uris = ["https://hw-prod.paulpbrandon.uk/oauth2/callback"] #will need to add all apps using this proxy here

    implicit_grant {
      id_token_issuance_enabled     = true
    }
  }

  optional_claims {
    id_token {
      name                  = "email"
      essential             = false
    }
    id_token {
      name                  = "groups"
      essential             = true
    }
    id_token {
      name                  = "preferred_username"
      essential             = false
    }
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }

    resource_access {
      id   = "37f7f235-527c-4136-accd-4a02d197296e" # openid
      type = "Scope"
    }

    resource_access {
      id   = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0" # email
      type = "Scope"
    }
  }
}

resource "azuread_application_password" "oauth2-proxy" {
  application_object_id = azuread_application.oauth2-proxy.object_id
}