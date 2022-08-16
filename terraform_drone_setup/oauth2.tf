resource "random_password" "default-oauth2-proxy-cookie-secret" {
  length           = 16
  special          = false
}

resource "helm_release" "default-oauth2-proxy" {
  name       = "default-oauth2-proxy"
  repository = "https://oauth2-proxy.github.io/manifests"
  chart      = "oauth2-proxy"
  version    = "6.2.2"

  set {
    name  = "metrics.enabled"
    value = false
  }
  set {
    name  = "config.clientID"
    value = azuread_application.oauth2-proxy.application_id
  }
  set {
    name  = "config.clientSecret"
    value = azuread_application_password.oauth2-proxy.value
  }
  set {
    name  = "config.cookieSecret"
    value = random_password.default-oauth2-proxy-cookie-secret.result
  }
  set {
    name  = "extraArgs.approval-prompt"
    value = "auto"
  }
  set {
    name  = "extraArgs.provider"
    value = "oidc"
  }
  set {
    name  = "extraArgs.email-domain"
    value = "*"
  }
  set {
    name  = "extraArgs.upstream"
    value = "file:///dev/null"
  }
  set {
    name  = "extraArgs.http-address"
    value = "0.0.0.0:4180"

  }
  set {
    name  = "extraArgs.oidc-issuer-url"
    value = "https://login.microsoftonline.com/${var.tenant_id}/v2.0"
  }
  set {
    name  = "extraArgs.oidc-email-claim"
    value = "preferred_username"
  }
  set {
    name  = "extraArgs.scope"
    value = "openid email profile"
  }
  set {
    name  = "extraArgs.allowed-group" #I think this can be specified multiple times for multiple groups, might be nice for it to take an array variable
    value = var.default_oauth_group
  }
  #set {
  #  name  = "extraArgs.oidc-groups-claim" #use this to treat application roles as groups, allowed groups will then work on this
  #  value = "roles"
  #ß}
  set {
    name  = "extraArgs.set-authorization-header"
    value = true
  }
  set {
    name  = "extraArgs.set-xauthrequest"
    value = true
  }
  set {
    name  = "extraArgs.pass-authorization-header"
    value = true
  }
  set {
    name  = "extraArgs.pass-access-token"
    value = true
  }
  set {
    name  = "extraArgs.skip-jwt-bearer-tokens"
    value = true
  }
  set {
    name  = "extraArgs.extra-jwt-issuers"
    value = "https://login.microsoftonline.com/${var.tenant_id}/v2.0=${azuread_application.oauth2-proxy.application_id}"
  }
}