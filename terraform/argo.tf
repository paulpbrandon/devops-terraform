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

#this may not like server side apply, it was acting like the URL was missing
#I ran an kubectl apply directly on the ConfigMap, and it started working
#removed this resource then reapplied, it still works, but the direct apply may have triggered something else
#may need a better way, generally seem to need hard restarts after changing these settings (Helm?)
#need the client secret in a secret too
resource "kubernetes_config_map_v1_data" "sso" {
  depends_on = [kubectl_manifest.argo]
  metadata {
    name = "argocd-cm"
    namespace = "argocd"
  }
  data = {
    "accounts.machine" = "apiKey"
    "admin.enabled" = "false"
    "statusbadge.enabled" = "true"
    "url" = "https://argo.${var.cluster_domain}"
    "dex.config" = <<-EOF
connectors:
  - type: github
    id: github
    name: GitHub
    config:
      clientID: ${var.argo_github_client_id}
      clientSecret: ${var.argo_github_client_secret}
      orgs:
      - name: ${var.argo_github_org}
EOF
  }
}

resource "kubernetes_config_map_v1_data" "sso-policy" {
  depends_on = [kubectl_manifest.argo]
  metadata {
    name = "argocd-rbac-cm"
    namespace = "argocd"
  }
  data = {
    "policy.default" = "role:readonly"
    "policy.csv" = <<-EOF
p, role:org-admin, applications, *, */*, allow
p, role:org-admin, clusters, get, *, allow
p, role:org-admin, repositories, get, *, allow
p, role:org-admin, repositories, create, *, allow
p, role:org-admin, repositories, update, *, allow
p, role:org-admin, repositories, delete, *, allow
p, role:org-admin, accounts, get, *, allow
p, role:org-admin, accounts, update, *, allow
p, role:machine, applications, *, */*, allow
g, "${var.argo_github_admin_group}", role:org-admin
g, "machine", role:machine
EOF
  }
}
