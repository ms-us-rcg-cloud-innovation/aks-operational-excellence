// turn on monitor alerts perview in the portal and run
//
// ```bash
// az monitor metrics alert list -g aks
// ```
// 
// take the result json and map it to terraform
// perhaps write a terraform for_each loop over json
resource "azurerm_monitor_metric_alert" "example" {
  name                = "Completed job count"
  resource_group_name = azurerm_resource_group.default.name
  scopes              = [azurerm_kubernetes_cluster.default.id]
  description         = "This alert monitors completed jobs (more than 6 hours ago)."

  criteria {
    metric_namespace = "Insights.Container/pods"
    metric_name      = "completedJobsCount"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 0.0


    dimension {
      name     = "controllerName"
      operator = "Include"
      values   = ["*"]
    }

    dimension {
      name     = "kubernetes namespace"
      operator = "Include"
      values   = ["*"]
    }
  }

  #   action {
  #     action_group_id = azurerm_monitor_action_group.main.id
  #   }
} 