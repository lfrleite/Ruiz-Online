param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'output')
)

. (Join-Path $PSScriptRoot '..\_Common\GraphHelpers.ps1')
Connect-GraphForScopes -Scopes @('DeviceManagementManagedDevices.Read.All')

$events = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/deviceManagement/mobileAppTroubleshootingEvents?$top=999'

$rows = foreach ($event in $events) {
    [pscustomobject]@{
        EventId = $event.id
        EventDateTimeUTC = $event.eventDateTime
        CorrelationId = $event.correlationId
        UserId = $event.userId
        DeviceId = $event.managedDeviceIdentifier
        DeviceName = $event.deviceName
        OS = $event.os
        OSVersion = $event.osVersion
        AppId = $event.applicationId
        AppName = $event.applicationDisplayName
        FailureCategory = $event.failureCategory
        FailureReason = $event.failureReason
        TroubleshootingErrorDetails = ConvertTo-CompactJson $event.troubleshootingErrorDetails
        Recomendacao = 'Investigar eventos com falha e agrupar por aplicativo, dispositivo e motivo.'
        Causa = "$($event.failureCategory) - $($event.failureReason)"
        Solucao = 'Validar atribuição, requisitos, detecção, dependências, versão do sistema, enrollment e logs do dispositivo.'
        Documentacao = 'https://learn.microsoft.com/graph/api/intune-devices-mobileapptroubleshootingevent-list'
    }
}

Export-GraphCsv -Data @($rows | Sort-Object EventDateTimeUTC -Descending) -Path (Join-Path $OutputDirectory 'intune-app-troubleshooting.csv')
