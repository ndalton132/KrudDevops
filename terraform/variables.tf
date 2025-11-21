variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default = ""
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = ""
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default = ""
}

variable "postgresql_server_name" {
  description = "Name of the PostgreSQL server"
  type        = string
  default = ""
}

variable "postgresql_admin_username" {
  description = "PostgreSQL admin username"
  type        = string
  sensitive   = true
  default = ""
}

variable "postgresql_admin_password" {
  description = "PostgreSQL admin password"
  type        = string
  sensitive   = true
  default = ""
}