$ErrorActionPreference="Stop"

$resourceGroupName="aks"
$root = $PSScriptRoot
$alertJson= Join-Path $root "alert_arm.json"

az monitor metrics alert list -g $resourceGroupName > $alertJson

# load alerts from the alert json
$alerts = Get-Content $alertJson | ConvertFrom-Json
$alertHcl = @()

foreach($alert in $alerts){
    $alertHcl += @{
        "name" = $alert.name
        "description" = $alert.description.split('.')[0]
        "criteria" = @($alert.criteria.allOf | foreach-object { 
            $criteria = $_
            return @{
                "metric_namespace" = $criteria.metricNamespace
                "metric_name" = $criteria.metricName
                "name" = $criteria.name
                "operator" = $criteria.operator
                "threshold" = $criteria.threshold
                "aggregation" = $criteria.timeAggregation
                "dimensions" = @($criteria.dimensions | foreach-object{
                    $dimension = $_
                    return @{
                        "name" = $dimension.name
                        "operator" = $dimension.operator
                        "values" = $dimension.values
                    }
                })
            }
        })
    }
}

$alertHcl | ConvertTo-Json -Depth 10 | out-file (join-path $root "alerts.json")    