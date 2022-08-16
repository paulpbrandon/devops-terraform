resource "helm_release" "sealed-secrets" {
  name       = "sealed-secrets"
  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart      = "sealed-secrets"
  namespace  = "kube-system"
  version    = "2.6.0"

  set {
    name  = "fullnameOverride"
    value = "sealed-secrets-controller"
  }
}