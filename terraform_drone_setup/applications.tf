data "azurerm_public_ip" "ingress-ip" {
  name                = "ingressIP"
  resource_group_name = data.azurerm_kubernetes_cluster.aks.node_resource_group
}

data "azurerm_dns_zone" "cluster-domain" {
  name                = var.cluster_domain
  resource_group_name = data.azurerm_kubernetes_cluster.aks.resource_group_name
}

resource "azurerm_dns_a_record" "helloworld" {
  count = length(var.envs)
  name                = "hw-${var.envs[count.index]}"
  zone_name           = data.azurerm_dns_zone.cluster-domain.name
  resource_group_name = data.azurerm_kubernetes_cluster.aks.resource_group_name
  ttl                 = 3600
  target_resource_id  = data.azurerm_public_ip.ingress-ip.id
}

resource "argocd_application" "helloworld" {
  count = length(var.envs)
  metadata {
    name      = "helloworld-${var.envs[count.index]}"
    labels    = {
      environment = var.envs[count.index]
    }
  }
  spec {
    project = "default"

    source {
      repo_url        = "git@github.com:nimbleapproach/argo-demo.git"
      path            = "kustomizehelloworld/overlays/hw-${var.envs[count.index]}"
      target_revision = "HEAD"
      kustomize {
        name_suffix   = var.envs[count.index]
      }
    }

    destination {
      server    = "https://kubernetes.default.svc"
      namespace = "hw-${var.envs[count.index]}"
    }

    sync_policy {
      automated = {
        prune       = true
        self_heal   = true
        allow_empty = true
      }
      sync_options = ["CreateNamespace=true", "RespectIgnoreDifferences=true"]
    }

    #allow app to be scaled without healing back to original state
    #can also just not define replicas in the application deployment, but this should give the flexibility to just
    #add and remove scaled objects as necessary
    ignore_difference {
      group         = "apps"
      kind          = "Deployment"
      json_pointers = ["/spec/replicas"]
    }
  }
}
