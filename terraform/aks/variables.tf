variable "name" {
  type    = string
  description = "Name of the AKS cluster"
  default = "aks"
}

variable "location" {
  type    = string
  description = "Location of AKS cluster"
  default = "East US 2"
}

variable "kubernetes_version" {
  type = string
  description = "Version of the kubernetes cluster to deploy"
}

