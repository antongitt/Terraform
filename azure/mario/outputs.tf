output "region" {
  description = "region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster name"
  value       = azurerm_kubernetes_cluster.cl.name
}

output "rg_name" {
  description = "Name of resource group"
  value       = azurerm_resource_group.rg.name
}