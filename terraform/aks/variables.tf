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

variable "node_surge" {
  type = string
  description = "The maximum number or percentage of nodes which will be added to the default Node Pool size during an upgrade"
  default = "33%"
  validation {
    condition = can(regex("^[0-9]+[%]?$", var.node_surge))
    error_message = "Value can be a positive integer or percentage"
  }
}