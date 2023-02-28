variable "resource_group" {
  type        = string
  description = "Name of resource group for AKS cluster"
}

variable "name" {
  type        = string
  description = "Name of the AKS cluster"
}

variable "location" {
  type        = string
  description = "Location of AKS cluster"
}

variable "kubernetes_version" {
  type        = string
  description = "Version of the kubernetes cluster to deploy"
}

variable "default_pool_size" {
  type        = number
  description = "Number of cluster nodes in default pool"
}
