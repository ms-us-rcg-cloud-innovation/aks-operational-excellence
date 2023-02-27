resource "azurerm_log_analytics_workspace" "default" {
  name                = "logs-${var.name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.default.name
  retention_in_days   = 30
}