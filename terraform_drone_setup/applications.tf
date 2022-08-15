data "azurerm_public_ip" "ingress-ip" {
  name                = "ingressIP"
  resource_group_name = data.azurerm_kubernetes_cluster.aks.node_resource_group
}

data "azurerm_dns_zone" "cluster-domain" {
  name                = var.cluster_domain
  resource_group_name = data.azurerm_kubernetes_cluster.aks.resource_group_name
}

resource "azurerm_dns_a_record" "hellworld-dev" {
  name                = "hw-dev"
  zone_name           = data.azurerm_dns_zone.cluster-domain.name
  resource_group_name = data.azurerm_kubernetes_cluster.aks.resource_group_name
  ttl                 = 3600
  target_resource_id  = data.azurerm_public_ip.ingress-ip.id
}

resource "argocd_application" "hellworld-dev" {
  metadata {
    name      = "helloworld"
    labels    = {
      development = "true"
    }
  }
  spec {
    project = "default"

    source {
      repo_url        = "git@github.com:nimbleapproach/argo-demo.git"
      path            = "kustomizehelloworld/overlays/hw-dev"
      target_revision = "HEAD"
      kustomize {
        name_suffix   = "dev"
      }
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "hw-dev"
    }

    sync_policy {
      automated = {
        prune       = true
        self_heal   = true
        allow_empty = true
      }
      sync_options = ["CreateNamespace=true"]
    }
  }
}


