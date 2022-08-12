data "kubectl_path_documents" "argo" {
    pattern = "../manifests/argo/*.yaml"
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

resource "kubectl_manifest" "argo" {
  for_each  = toset(data.kubectl_path_documents.argo.documents)
  yaml_body = each.value
  override_namespace = kubernetes_namespace.argocd.metadata.0.name
  depends_on = [helm_release.ingress-controller]
}
