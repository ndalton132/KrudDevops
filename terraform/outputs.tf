output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.main.name
}

output "aks_kubeconfig" {
  value     = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive = true
}

output "postgresql_server_fqdn" {
  value = azurerm_postgresql_flexible_server.main.fqdn
}

output "postgresql_connection_string" {
  value     = "postgresql://${var.postgresql_admin_username}@${azurerm_postgresql_flexible_server.main.fqdn}:5432/myappdb"
  sensitive = true
}

output "postgresql_database_name" {
  value = azurerm_postgresql_flexible_server_database.main.name
  description = "PostgreSQL database name"
}

output "resource_group_name" {
  value       = azurerm_resource_group.main.name
  description = "The name of the resource group."
}