resource "azurerm_virtual_network" "default" {
  name                = "vnet-${var.name}"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.default.name

  subnet {
    name           = "snet-${var.name}-nodepool"
    address_prefix = "10.1.0.0/24"
  }
}