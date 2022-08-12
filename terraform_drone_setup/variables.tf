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
