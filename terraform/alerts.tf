
/* resource "azurerm_monitor_metric_alert" "example" {
  name                = "KubePodCrashLooping"
  resource_group_name = azurerm_resource_group.default.name
  scopes              = [azurerm_kubernetes_cluster.default.id]
  description         = "Detect when a pod is crash looping."

  criteria {
    metric_namespace = "Microsoft.Storage/storageAccounts"
    metric_name      = "Transactions"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 50

    dimension {
      name     = "ApiName"
      operator = "Include"
      values   = ["*"]
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
} */