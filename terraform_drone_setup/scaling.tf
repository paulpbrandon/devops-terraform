data "kubectl_path_documents" "scaling" {
  pattern = "../manifests/scaling/*.yaml"
}

resource "kubectl_manifest" "scaling" {
  for_each  = toset(data.kubectl_path_documents.scaling.documents)
  yaml_body = each.value
  depends_on = [helm_release.prometheus]
}