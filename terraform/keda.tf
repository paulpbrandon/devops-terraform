resource "kubernetes_namespace" "keda" {
  metadata {
    name = "keda"
  }

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

resource "helm_release" "keda" {
  name       = "keda"
  repository = "https://kedacore.github.io/charts"
  chart      = "keda"
  namespace  = kubernetes_namespace.keda.metadata.0.name
  version    = "2.8.1"
}