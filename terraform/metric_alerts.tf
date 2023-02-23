locals{
    alerts_json = file("${path.module}/alerts.json")
    alerts = jsondecode(local.alerts_json)
}

// turn on monitor alerts perview in the portal and run
//
// ```bash
// az monitor metrics alert list -g aks
// ```
// 
// take the result json and map it to terraform
// perhaps write a terraform for_each loop over json
resource "azurerm_monitor_metric_alert" "alert" {
  for_each = {
    for alert in local.alerts:
    alert.name => alert
  } 

  name                = each.key
  resource_group_name = azurerm_resource_group.default.name
  scopes              = [azurerm_kubernetes_cluster.default.id]
  description         = each.value.description

  
  dynamic "criteria" {
    for_each = {
        for criteria in each.value.criteria:
        criteria.metric_name => criteria        
    }
    content {
        metric_namespace = criteria.value.metric_namespace
        metric_name = criteria.value.metric_name
        aggregation = criteria.value.aggregation
        threshold = criteria.value.threshold
        operator = criteria.value.operator
        
        dynamic "dimension"{
            for_each = {
                for dimension in criteria.value.dimensions:
                dimension.name => dimension
            }
            content {
                name = dimension.value.name
                operator = dimension.value.operator
                values = dimension.value.values
            }        
        }
    }    
  }

  #   action {
  #     action_group_id = azurerm_monitor_action_group.main.id
  #   }
} 