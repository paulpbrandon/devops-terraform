resource "kubernetes_namespace" "drone" {
  metadata {
    name = "drone"
  }
  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

resource "random_password" "drone-rpc-secret" {
  length           = 16
  special          = false
}

resource "kubernetes_secret" "drone-secret" {
  metadata {
    name = "drone-secret"
    namespace = kubernetes_namespace.drone.metadata.0.name
  }

  data = {
    githubclientid     = var.github_client_id
    githubclientsecret = var.github_client_secret
    rpcsecret          = random_password.drone-rpc-secret.result
    host               = "drone.${var.cluster_domain}"
    initial_admin_user = "username:machine_admin,machine:true,admin:true,token:${var.drone_admin_token}"
  }
}

data "kubectl_path_documents" "drone" {
    pattern = "../manifests/drone/*.yaml"
}

resource "kubectl_manifest" "drone" {
  for_each  = toset(data.kubectl_path_documents.drone.documents)
  yaml_body = each.value
  override_namespace = kubernetes_namespace.drone.metadata.0.name
  depends_on = [helm_release.ingress-controller, kubernetes_secret.drone-secret]
}
