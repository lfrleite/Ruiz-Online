param(
    [int]$AlertDaysBeforeExpiration = 30,
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'output')
)

. (Join-Path $PSScriptRoot '..\_Common\GraphHelpers.ps1')
Connect-GraphForScopes -Scopes @('DeviceManagementServiceConfig.Read.All')

$rows = [System.Collections.Generic.List[object]]::new()

$vppTokens = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/deviceAppManagement/vppTokens'
foreach ($token in $vppTokens) {
    $expiration = if ($token.expirationDateTime) { [datetime]$token.expirationDateTime } else { $null }
    $days = if ($expiration) { [math]::Floor(($expiration.ToUniversalTime() - (Get-Date).ToUniversalTime()).TotalDays) } else { $null }
    $rows.Add([pscustomobject]@{
        TipoConector = 'Apple VPP'
        Nome = $token.organizationName
        Conta = $token.appleId
        Estado = $token.state
        UltimaSincronizacaoUTC = $token.lastSyncDateTime
        StatusSincronizacao = $token.lastSyncStatus
        ExpiracaoUTC = $token.expirationDateTime
        DiasParaExpirar = $days
        Detalhes = ConvertTo-CompactJson $token
        Recomendacao = if ($days -ne $null -and $days -le $AlertDaysBeforeExpiration) { 'Renovar token antes da expiração.' } elseif ($token.lastSyncStatus -notin @('completed','success')) { 'Investigar falha de sincronização.' } else { 'Sem alerta inicial.' }
        Causa = "Estado=$($token.state); LastSyncStatus=$($token.lastSyncStatus)"
        Solucao = 'Renovar o token com a mesma conta, validar sincronização e revisar aplicações associadas.'
        Documentacao = 'https://learn.microsoft.com/graph/api/intune-onboarding-vpptoken-list'
    })
}

$apns = (Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/deviceManagement/applePushNotificationCertificate')[0]
$rows.Add([pscustomobject]@{
    TipoConector = 'Apple Push Notification Service'
    Nome = 'APNs'
    Conta = $apns.appleIdentifier
    Estado = if ($apns.certificateSerialNumber) { 'Configurado' } else { 'Nao configurado' }
    UltimaSincronizacaoUTC = $null
    StatusSincronizacao = $null
    ExpiracaoUTC = $apns.expirationDateTime
    DiasParaExpirar = if ($apns.expirationDateTime) { [math]::Floor(([datetime]$apns.expirationDateTime - (Get-Date).ToUniversalTime()).TotalDays) } else { $null }
    Detalhes = ConvertTo-CompactJson $apns
    Recomendacao = 'Acompanhar validade e renovar antes da expiração.'
    Causa = 'Certificado necessário para gerenciamento de dispositivos Apple.'
    Solucao = 'Renovar com o mesmo Apple ID e validar comunicação após a troca.'
    Documentacao = 'https://learn.microsoft.com/graph/api/intune-onboarding-applepushnotificationcertificate-get'
})

$mtd = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/deviceManagement/mobileThreatDefenseConnectors'
foreach ($connector in $mtd) {
    $rows.Add([pscustomobject]@{
        TipoConector = 'Mobile Threat Defense'
        Nome = $connector.partnerUnresponsivenessThresholdInDays
        Conta = ''
        Estado = $connector.partnerState
        UltimaSincronizacaoUTC = $connector.lastHeartbeatDateTime
        StatusSincronizacao = $connector.partnerState
        ExpiracaoUTC = $null
        DiasParaExpirar = $null
        Detalhes = ConvertTo-CompactJson $connector
        Recomendacao = if ($connector.partnerState -notin @('available','enabled')) { 'Investigar estado do parceiro MTD.' } else { 'Sem alerta inicial.' }
        Causa = "PartnerState=$($connector.partnerState)"
        Solucao = 'Validar integração, heartbeat, plataformas habilitadas e políticas dependentes.'
        Documentacao = 'https://learn.microsoft.com/graph/api/intune-onboarding-mobilethreatdefenseconnector-list'
    })
}

try {
    $dep = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/beta/deviceManagement/depOnboardingSettings'
    foreach ($connector in $dep) {
        $rows.Add([pscustomobject]@{
            TipoConector = 'Apple Automated Device Enrollment'
            Nome = $connector.tokenName
            Conta = $connector.appleIdentifier
            Estado = $connector.tokenStatus
            UltimaSincronizacaoUTC = $connector.lastSuccessfulSyncDateTime
            StatusSincronizacao = $connector.lastSyncErrorCode
            ExpiracaoUTC = $connector.tokenExpirationDateTime
            DiasParaExpirar = if ($connector.tokenExpirationDateTime) { [math]::Floor(([datetime]$connector.tokenExpirationDateTime - (Get-Date).ToUniversalTime()).TotalDays) } else { $null }
            Detalhes = ConvertTo-CompactJson $connector
            Recomendacao = 'Revisar validade e última sincronização do token ADE.'
            Causa = "TokenStatus=$($connector.tokenStatus); LastSyncError=$($connector.lastSyncErrorCode)"
            Solucao = 'Renovar token, sincronizar e validar perfis de enrollment.'
            Documentacao = 'https://learn.microsoft.com/graph/api/resources/intune-onboarding-deponboardingsetting'
        })
    }
}
catch {
    Write-Warning "Não foi possível consultar DEP/ADE beta: $($_.Exception.Message)"
}

Export-GraphCsv -Data $rows.ToArray() -Path (Join-Path $OutputDirectory 'intune-conectores.csv')
