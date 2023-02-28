
resource "azurerm_kubernetes_cluster" "default" {
  name                = var.name
  location            = var.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = var.name
  kubernetes_version  = var.kubernetes_version


  default_node_pool {
    name           = "default"
    node_count     = var.default_pool_size
    vm_size        = "standard_d2as_v5"
    vnet_subnet_id = azurerm_virtual_network.default.subnet.*.id[0]
  }

  identity {
    type = "SystemAssigned"
  }

  # these lines turns on container insights
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.default.id
  }
}

# see https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-custom-metrics?tabs=cli#enable-custom-metrics
# The preview feature for role assignment this will be added automatically.
# For now we need to ad it manually.
# The id is hard to find, it is part of the "oms_agent" output attribute and was moved from addon_profiles in the later version of the providers.
# Use object_id and specify check AAD otherwise it will go into an infinite loop.
# https://github.com/hashicorp/terraform-provider-azurerm/pull/7056
resource "azurerm_role_assignment" "omsagent-aks" {
  scope                            = azurerm_kubernetes_cluster.default.id
  role_definition_name             = "Monitoring Metrics Publisher"
  principal_id                     = azurerm_kubernetes_cluster.default.oms_agent[0].oms_agent_identity[0].object_id
  skip_service_principal_aad_check = false
}
