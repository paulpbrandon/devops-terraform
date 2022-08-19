#we will setup prometheus in this pipeline as the scrape config will include a bearer token for drone
#but we won't use the machine admin, we'll create a non admin machine account for it which we'll need
#the drone provider for, you can't create multiple machine accounts up front, then we shouldn't have to worry about the token so much
#resource "drone_user" "metrics" {
#  login = "metrics"
#  admin = false
#  active = true
#  machine = true
#}
#The above creates the user but get nothing back for drone_user.metrics.token, provider may need updating
#We'll have to add an extra step where drone CLI is used to create user with a token and add as a tfvar

resource "kubernetes_namespace" "metrics" {
  metadata {
    name = "metrics"
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"
  namespace  = kubernetes_namespace.metrics.metadata.0.name
  version    = "15.12.0"

  #values = [templatefile("../helm/prometheus-values.yaml", {drone_metrics_bearer_token = drone_user.metrics.token})]
  values = [templatefile("../helm/prometheus-values.yaml", {drone_metrics_bearer_token = var.drone_metrics_token})]
}



