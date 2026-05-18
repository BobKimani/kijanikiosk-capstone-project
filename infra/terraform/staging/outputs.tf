output "staging_namespace" {
  description = "The Kubernetes namespace provisioned for staging."
  value       = kubernetes_namespace.kijani_staging.metadata[0].name
}
