resource_group     = "aks_dev"
name               = "k8s"
location           = "eastus"
kubernetes_version = "1.25.4"
default_pool_size  = 3
node_surge         = "33%"
