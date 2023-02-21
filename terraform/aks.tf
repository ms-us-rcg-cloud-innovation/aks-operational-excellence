
resource "azurerm_kubernetes_cluster" "default" {
  name                = var.name
  location            = var.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = var.name

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "standard_d2as_v5"
    vnet_subnet_id = azurerm_virtual_network.default.subnet.*.id[0]

  }

  identity {
    type = "SystemAssigned"
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.default.id
  }
}