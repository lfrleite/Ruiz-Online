param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'output')
)

. (Join-Path $PSScriptRoot '..\_Common\GraphHelpers.ps1')
Connect-GraphForScopes -Scopes @('IdentityRiskyUser.Read.All','IdentityRiskEvent.Read.All')

$riskyUsers = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/identityProtection/riskyUsers?$top=999'
$detections = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/identityProtection/riskDetections?$top=999'
$riskyIndex = @{}
foreach ($item in $riskyUsers) { $riskyIndex[[string]$item.id] = $item }

$rows = foreach ($detection in $detections) {
    $user = $riskyIndex[[string]$detection.userId]
    [pscustomobject]@{
        RiskDetectionId = $detection.id
        UserId = $detection.userId
        UserPrincipalName = $detection.userPrincipalName
        UserDisplayName = $user.userDisplayName
        RiskLevelUsuario = $user.riskLevel
        RiskStateUsuario = $user.riskState
        RiskDetailUsuario = $user.riskDetail
        RiskEventType = $detection.riskEventType
        RiskLevelDeteccao = $detection.riskLevel
        RiskStateDeteccao = $detection.riskState
        RiskDetailDeteccao = $detection.riskDetail
        DataDeteccaoUTC = $detection.detectedDateTime
        UltimaAtualizacaoUTC = $detection.lastUpdatedDateTime
        IPAddress = $detection.ipAddress
        Localizacao = ConvertTo-CompactJson $detection.location
        CorrelationId = $detection.correlationId
        Source = $detection.source
        Recomendacao = if ($detection.riskLevel -eq 'high' -and $detection.riskState -notin @('remediated','dismissed')) { 'Prioridade: investigar e remediar detecção de alto risco.' } elseif ($detection.riskState -notin @('remediated','dismissed')) { 'Investigar detecção de risco aberta.' } else { 'Registrar evidência de remediação.' }
        Causa = "$($detection.riskEventType) - $($detection.riskDetail)"
        Solucao = 'Investigar sign-in, confirmar comprometimento, redefinir credenciais, revogar sessões e aplicar política de risco conforme procedimento.'
        Documentacao = 'https://learn.microsoft.com/graph/api/resources/identityprotection-overview'
    }
}

Export-GraphCsv -Data @($rows | Sort-Object DataDeteccaoUTC -Descending) -Path (Join-Path $OutputDirectory 'identity-protection-riscos.csv')
