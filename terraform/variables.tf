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

variable github_client_id {
        type = string
}

variable github_client_secret {
        type = string
        sensitive = true
}
