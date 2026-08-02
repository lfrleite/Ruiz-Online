param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'output')
)

. (Join-Path $PSScriptRoot '..\_Common\GraphHelpers.ps1')
Connect-GraphForScopes -Scopes @('Organization.Read.All')

$skus = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/subscribedSkus'

$rows = foreach ($sku in $skus) {
    $enabled = [int]$sku.prepaidUnits.enabled
    $consumed = [int]$sku.consumedUnits
    $available = $enabled - $consumed
    $utilization = if ($enabled -gt 0) { [math]::Round(($consumed / $enabled) * 100, 2) } else { $null }

    foreach ($plan in $sku.servicePlans) {
        [pscustomobject]@{
            DataColetaUTC = (Get-Date).ToUniversalTime()
            SkuId = $sku.skuId
            SkuPartNumber = $sku.skuPartNumber
            StatusSku = $sku.capabilityStatus
            UnidadesHabilitadas = $enabled
            UnidadesConsumidas = $consumed
            UnidadesDisponiveis = $available
            PercentualUtilizacao = $utilization
            ServicePlanId = $plan.servicePlanId
            ServicePlanName = $plan.servicePlanName
            StatusServicePlan = $plan.provisioningStatus
            AplicaSeA = $plan.appliesTo
            Recomendacao = if ($available -lt 0) { 'Revisar consumo acima da capacidade adquirida.' } elseif ($available -le 5) { 'Acompanhar disponibilidade de licencas.' } elseif ($plan.provisioningStatus -notin @('Success','PendingInput')) { 'Revisar estado do service plan.' } else { 'Sem alerta inicial.' }
            Causa = if ($available -lt 0) { 'Unidades consumidas superiores às unidades habilitadas.' } elseif ($available -le 5) { 'Baixa quantidade de unidades disponíveis.' } else { "Estado do plano: $($plan.provisioningStatus)" }
            Solucao = 'Validar atribuições, licenças não utilizadas, necessidade de compra e dependências dos recursos de segurança.'
            Documentacao = 'https://learn.microsoft.com/graph/api/subscribedsku-list'
        }
    }
}

Export-GraphCsv -Data @($rows) -Path (Join-Path $OutputDirectory 'licencas-service-plans.csv')
