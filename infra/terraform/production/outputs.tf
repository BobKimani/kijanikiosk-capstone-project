output "production_namespace" {
  description = "The Kubernetes namespace provisioned for production."
  value       = kubernetes_namespace.kijani_production.metadata[0].name
}
