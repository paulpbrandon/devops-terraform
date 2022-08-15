variable dns_prefix {
    default = "aksdemo"
}

variable cluster_name {
    default = "pauls-demo-aks-cluster"
}

variable node_count {
    default = 1
}

variable network_type {
    default = "kubenet"

    validation {
        condition     = contains(["azure", "kubenet", "none"], var.network_type)
        error_message = "Invalid network type."
    } 
}

variable drone_github_client_id {
        type = string
}

variable drone_github_client_secret {
        type = string
        sensitive = true
}

variable cluster_domain {
        type = string
}

variable "drone_admin_token" {
         type = string
         sensitive = true
}

variable argo_github_client_id {
  type = string
}

variable argo_github_client_secret {
  type = string
  sensitive = true
}

variable argo_github_org {
  type = string
}

variable argo_github_admin_group {
  type = string
}
