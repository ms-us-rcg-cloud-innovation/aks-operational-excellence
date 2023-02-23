locals {
  alerts_json = file("${path.module}/alerts.json")
  alerts      = jsondecode(local.alerts_json)
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
    for alert in local.alerts :
    alert.name => alert
  }

  name                = each.key
  resource_group_name = azurerm_resource_group.default.name
  scopes              = [azurerm_kubernetes_cluster.default.id]
  description         = each.value.description


  dynamic "criteria" {
    for_each = {
      for criteria in each.value.criteria :
      criteria.metric_name => criteria
    }
    content {
      metric_namespace = criteria.value.metric_namespace
      metric_name      = criteria.value.metric_name
      aggregation      = criteria.value.aggregation
      threshold        = criteria.value.threshold
      operator         = criteria.value.operator

      dynamic "dimension" {
        for_each = {
          for dimension in criteria.value.dimensions :
          dimension.name => dimension
        }
        content {
          name     = dimension.value.name
          operator = dimension.value.operator
          values   = dimension.value.values
        }
      }
    }
  }

  #   action {
  #     action_group_id = azurerm_monitor_action_group.main.id
  #   }
}

resource "azurerm_monitor_metric_alert" "job_completed_more_than_six_hours" {
  name                = "Jobs completed more than 6 hours ago for aks CI-11"
  description         = "This alert monitors completed jobs (more than 6 hours ago)"
  resource_group_name = azurerm_resource_group.default.name
  scopes              = [azurerm_kubernetes_cluster.default.id]

  criteria {
    name             = "Metric1"
    metric_name      = "completedJobsCount"
    metric_namespace = "Insights.Container/pods"
    threshold        = 0.0
    operator         = "GreaterThan"
    aggregation      = "Average"

    dimension {
      values   = ["*"]
      name     = "controllerName"
      operator = "Include"
    }

    dimension {
      values   = ["*"]
      name     = "kubernetes namespace"
      operator = "Include"
    }
  }
}

resource "azruerm_monitor_metric_alert" "node_cpu_utilization_high" {
  name        = "Node CPU utilization high for aks CI-1"
  description = "Node CPU utilization across the cluster"

  resource_group_name = azurerm_resource_group.default.name
  scopes              = [azurerm_kubernetes_cluster.default.id]

  criteria {
    name             = "Metric1"
    metric_name      = "cpuUsagePercentage"
    metric_namespace = "Insights.Container/nodes"
    threshold        = 80.0
    operator         = "GreaterThan"
    aggregation      = "Average"

    dimension {
      values   = ["*"]
      name     = "host"
      operator = "Include"
    }
  }
}

resource "azurerm_monitor_metric_alert" "disk_usage_high" {
  description = "This alert monitors disk usage for all nodes and storage devices"
  name        = "Disk usage high for aks CI-5"

  resource_group_name = azurerm_resource_group.default.name
  scopes              = [azurerm_kubernetes_cluster.default.id]

  criteria {
    name             = "Metric1"
    metric_namespace = "Insights.Container/nodes"
    metric_name      = "DiskUsedPercentage"
    threshold        = 80.0
    operator         = "GreaterThan"
    aggregation      = "Average"
    dimension {
      values = [
        "*"
      ]
      name     = "host"
      operator = "Include"
    }
    dimension {
      values = [
        "*"
      ]
      name     = "device"
      operator = "Include"
    }
  }
}

resource "azurerm_monitor_metric_alert" "nodes_not_read_status" {

  description         = "Node status monitoring"
  name                = "Nodes in not ready status for aks CI-3"
  resource_group_name = azurerm_resource_group.default.name
  scopes              = [azurerm_kubernetes_cluster.default.id]

  criteria {
    name             = "Metric1"
    metric_namespace = "Insights.Container/nodes"
    metric_name      = "nodesCount"
    threshold        = 0.0
    dimension {
      values = [
        "NotReady"
      ]
      name     = "status"
      operator = "Include"
    }
    operator    = "GreaterThan"
    aggregation = "Average"
  }
}

resource "azurerm_monitor_metric_alert" "high_node_memory_utilization" {
  description         = "Node working set memory utilization across the cluster"
  name                = "Node working set memory utilization high for aks CI-2"
  resource_group_name = azurerm_resource_group.default.name
  scopes              = [azurerm_kubernetes_cluster.default.id]

  criteria {
    name             = "Metric1"
    metric_namespace = "Insights.Container/nodes"
    metric_name      = "memoryWorkingSetPercentage"
    threshold        = 80.0
    dimension {
      values = [
        "*"
      ]
      name     = "host"
      operator = "Include"
    }

    operator    = "GreaterThan"
    aggregation = "Average"
  }
}

resource "azurerm_monitor_metric_alert" "containers_oom_killed" {
  description         = "This alert monitors number of containers killed due to out of memory(OOM) error"
  name                = "Containers getting OOM killed for aks CI-6"
  resource_group_name = azurerm_resource_group.default.name
  scopes              = [azurerm_kubernetes_cluster.default.id]

  criteria {
    name             = "Metric1"
    metric_namespace = "Insights.Container/pods"
    metric_name      = "oomKilledContainerCount"
    threshold        = 0.0
    dimension {
      values = [
        "*"
      ]
      name     = "kubernetes namespace"
      operator = "Include"
    }
    dimension {
      values = [
        "*"
      ]
      name     = "controllerName"
      operator = "Include"
    }

    operator    = "GreaterThan"
    aggregation = "Average"
  }
}

resource "azurerm_monitor_metric_alert" "high_container_cpu_usage" {
  resource_group_name = azurerm_resource_group.default.name
  scopes              = [azurerm_kubernetes_cluster.default.id]

  description = "This alert monitors container CPU usage"
  name        = "Container CPU usage violates the configured threshold for aks CI-19"
  criteria {
    name             = "Metric1"
    metric_namespace = "Insights.Container/containers"
    metric_name      = "cpuThresholdViolated"
    threshold        = 0.0
    dimension {
      values = [
        "*"
      ]
      name     = "controllerName"
      operator = "Include"
    }
    dimension {
      values = [
        "*"
      ]
      name     = "kubernetes namespace"
      operator = "Include"
    }
    operator    = "GreaterThan"
    aggregation = "Average"
  }
}

resource "azurerm_monitor_metric_alert" "high_container_memory" {
  resource_group_name = azurerm_resource_group.default.name
  scopes              = [azurerm_kubernetes_cluster.default.id]

  description = "This alert monitors container working set memory usage"
  name        = "Container working set memory usage violates the configured threshold for aks CI-20"
  criteria {
    name             = "Metric1"
    metric_namespace = "Insights.Container/containers"
    metric_name      = "memoryWorkingSetThresholdViolated"
    threshold        = 0.0
    dimension {
      values = [
        "*"
      ]
      name     = "controllerName"
      operator = "Include"
    }
    dimension {
      values = [
        "*"
      ]
      name     = "kubernetes namespace"
      operator = "Include"
    }

    operator    = "GreaterThan"
    aggregation = "Average"
  }

}

resource "azurerm_monitor_metric_alert" "pods_in_failed_state" {
  resource_group_name = azurerm_resource_group.default.name
  scopes              = [azurerm_kubernetes_cluster.default.id]

  description = "Pod status monitoring"
  name        = "Pods in failed state for aks CI-4"
  criteria {
    name             = "Metric1"
    metric_namespace = "Insights.Container/pods"
    metric_name      = "podCount"
    threshold        = 0.0
    dimension {
      values = [
        "Failed"
      ]
      name     = "phase"
      operator = "Include"
    }
    operator    = "GreaterThan"
    aggregation = "Average"
  }
}

resource "azurerm_monitor_metric_alert" "persistent_volume_threshold_violated" {
  resource_group_name = azurerm_resource_group.default.name
  scopes              = [azurerm_kubernetes_cluster.default.id]

  description = "This alert monitors PV usage"
  name        = "PV usage violates the configured threshold for aks CI-21"

  criteria {
    name             = "Metric1"
    metric_namespace = "Insights.Container/persistentvolumes"
    metric_name      = "pvUsageThresholdViolated"
    threshold        = 0.0
    dimension {
      values = [
        "*"
      ]
      name     = "podName"
      operator = "Include"
    }
    dimension {
      values = [
        "*"
      ]
      name     = "kubernetesNamespace"
      operator = "Include"
    }
    operator    = "GreaterThan"
    aggregation = "Average"
  }
}

resource "azurerm_monitor_metric_alert" "pods_not_in_ready_state" {
  resource_group_name = azurerm_resource_group.default.name
  scopes              = [azurerm_kubernetes_cluster.default.id]

  description = "This alert monitors pods in the ready state"
  name        = "Pods not in ready state for aks CI-8"
  criteria {
    name             = "Metric1"
    metric_namespace = "Insights.Container/pods"
    metric_name      = "PodReadyPercentage"
    threshold        = 80.0
    dimension {
      values = [
        "*"
      ]
      name     = "controllerName"
      operator = "Include"
    }
    dimension {
      values = [
        "*"
      ]
      name     = "kubernetes namespace"
      operator = "Include"
    }
    operator    = "LessThan"
    aggregation = "Average"
  }
}

resource "azurerm_monitor_metric_alert" "container_restart_exceeds_threshold" {

  description         = "This alert monitors number of containers restarting across the cluster"
  name                = "Restarting container count for aks CI-7"
  resource_group_name = azurerm_resource_group.default.name
  scopes              = [azurerm_kubernetes_cluster.default.id]

  criteria {
    name             = "Metric1"
    metric_namespace = "Insights.Container/pods"
    metric_name      = "restartingContainerCount"
    threshold        = 0.0
    dimension {
      values = [
        "*"
      ]
      name     = "kubernetes namespace"
      operator = "Include"
    }
    dimension {
      values = [
        "*"
      ]
      name     = "controllerName"
      operator = "Include"
    }

    operator    = "GreaterThan"
    aggregation = "Average"
  }
}