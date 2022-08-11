resource "random_password" "drone-rpc-secret" {
  length           = 16
  special          = false
}

resource "kubernetes_secret" "drone-secret" {
  metadata {
    name = "drone-secret"
  }

  data = {
    githubclientid = var.github_client_id
    githubclientsecret = var.github_client_secret
    rpcsecret = random_password.drone-rpc-secret.result
  }
}

data "kubectl_path_documents" "drone" {
    pattern = "../manifests/drone/*.yaml"
}

resource "kubernetes_namespace" "drone" {
  metadata {
    name = "drone"
  }
  depends_on = [
    azurerm_kubernetes_cluster.aks,
  ]
}

resource "kubectl_manifest" "drone" {
    for_each  = toset(data.kubectl_path_documents.drone.documents)
    yaml_body = each.value
}
