variable cluster_name {
    default = "pauls-demo-aks-cluster"
}

variable cluster_domain {
  type = string
}

variable github_org {
  type = string
}

variable "drone_admin_token" {
  type = string
  sensitive = true
}

variable "tenant_id" {
  type = string
}

variable "argo_token" {
  type = string
  sensitive = true
}

variable "default_oauth_group" {
  type = string
}

variable "envs" {
  type = list(string)
  default = ["dev", "prod"]
}
