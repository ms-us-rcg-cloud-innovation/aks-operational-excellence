
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

# see https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-custom-metrics?tabs=cli#enable-custom-metrics
# the preview feature for role assignment this will be added automatically
# for now we need to ad it manually
# the id is hard to find, it is part of the "oms_agent" output attribute and was moved from addon_profiles in the later version of the providers
# https://github.com/hashicorp/terraform-provider-azurerm/pull/7056
resource "azurerm_role_assignment" "omsagent-aks" {
  scope                            = azurerm_kubernetes_cluster.default.id
  role_definition_name             = "Monitoring Metrics Publisher"
  principal_id                     = azurerm_kubernetes_cluster.default.oms_agent[0].oms_agent_identity[0].object_id
  skip_service_principal_aad_check = false
}