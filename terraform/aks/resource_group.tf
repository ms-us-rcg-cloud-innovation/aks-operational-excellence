resource "azurerm_resource_group" "default" {
  name     = var.resource_group
  location = var.location
}
