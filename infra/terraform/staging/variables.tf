variable "kubeconfig_path" {
  description = "Path to the kubeconfig file used by Terraform to connect to the Kubernetes cluster."
  type        = string
  default     = "~/.kube/config"
}

variable "namespace" {
  description = "Kubernetes namespace for the staging environment."
  type        = string
  default     = "kijani-staging"
}
