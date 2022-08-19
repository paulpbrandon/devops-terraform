data "kubectl_path_documents" "crds" {
  pattern = "../manifests/crds/*.yaml"
}

data "kubectl_path_documents" "certs" {
  pattern = "../manifests/certs/*.yaml"
}

resource "kubernetes_namespace" "ingress" {
  metadata {
    name = "ingress-ctl"
  }

  depends_on = [
    azurerm_kubernetes_cluster.aks
  ]
}

resource "kubectl_manifest" "crds" {
  for_each  = toset(data.kubectl_path_documents.crds.documents)
  yaml_body = each.value
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = kubernetes_namespace.ingress.metadata.0.name
  version    = "1.9.1"
}

resource "kubectl_manifest" "certs" {
  for_each  = toset(data.kubectl_path_documents.certs.documents)
  yaml_body = each.value

  depends_on = [
    helm_release.cert_manager
  ]
}

resource "helm_release" "ingress-controller" {
  name             = "ingress-controller"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.2.1"
  namespace        = kubernetes_namespace.ingress.metadata.0.name

  depends_on = [
    azurerm_public_ip.ingress-ip
  ]

  set {
    name  = "controller.service.annotations.\"service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path\""
    value = "/healthz"
  }

  set {
    name  = "controller.nodeSelector.kubernetes\\.io/os"
    value = "linux"
  }

  set {
    name  = "controller.extraArgs.enable-ssl-passthrough"
    value = ""
  }

  set {
      name  = "controller.service.loadBalancerIP"
      value = azurerm_public_ip.ingress-ip.ip_address
    }

  set {
    name  = "controller.metrics.enabled"
    value = true
  }

  set {
    name  = "controller.podAnnotations.\"prometheus\\.io/path\""
    value = "/metrics"
  }

  set {
    name  = "controller.podAnnotations.\"prometheus\\.io/scrape\""
    value = "true"
    type = "string"
  }

  set {
    name  = "controller.podAnnotations.\"prometheus\\.io/port\""
    value = "10254"
    type = "string"
  }
  #when metrics enabled nginx creates a separate service for metrics
  #however the pod annotations above will apply to the metrics pod AND the controller pod
  #the controller pod will not report metrics, so you see an unknown in prometheus
  #alternative is not to do pod annotation based scraping for this and and explicitly configure the scrape target
}

resource "kubernetes_config_map_v1_data" "ingress-controller" {
  depends_on = [helm_release.ingress-controller]
  metadata {
    name = "ingress-controller-ingress-nginx-controller"
    namespace = kubernetes_namespace.ingress.metadata.0.name
  }
  data = {
    proxy-buffer-size = "8k"
  }
}
