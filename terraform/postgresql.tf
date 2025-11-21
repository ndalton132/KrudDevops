resource "azurerm_postgresql_flexible_server" "main" {
  name                   = var.postgresql_server_name
  resource_group_name    = azurerm_resource_group.main.name
  location               = azurerm_resource_group.main.location
  version                = "14"
  administrator_login    = var.postgresql_admin_username
  administrator_password = var.postgresql_admin_password

  storage_mb = 32768
sku_name = "B_Standard_B1ms"
  public_network_access_enabled = true

}

resource "azurerm_postgresql_flexible_server_database" "main" {
  name      = "todo_database"
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = "en_US.utf8"
  charset   = "utf8"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_aks" {
  name             = "allow-aks-subnet"
  server_id        = azurerm_postgresql_flexible_server.main.id
  start_ip_address = cidrhost(azurerm_subnet.aks.address_prefixes[0], 0)
  end_ip_address   = cidrhost(azurerm_subnet.aks.address_prefixes[0], -1)
}