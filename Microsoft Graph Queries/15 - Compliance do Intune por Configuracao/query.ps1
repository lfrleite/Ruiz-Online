param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'output')
)

. (Join-Path $PSScriptRoot '..\_Common\GraphHelpers.ps1')
Connect-GraphForScopes -Scopes @('DeviceManagementConfiguration.Read.All')

$summaries = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicySettingStateSummaries'
$summaryRows = [System.Collections.Generic.List[object]]::new()
$detailRows = [System.Collections.Generic.List[object]]::new()

foreach ($summary in $summaries) {
    $summaryRows.Add([pscustomobject]@{
        SummaryId = $summary.id
        Setting = $summary.setting
        SettingName = $summary.settingName
        PlatformType = $summary.platformType
        UnknownDeviceCount = $summary.unknownDeviceCount
        NotApplicableDeviceCount = $summary.notApplicableDeviceCount
        CompliantDeviceCount = $summary.compliantDeviceCount
        RemediatedDeviceCount = $summary.remediatedDeviceCount
        NonCompliantDeviceCount = $summary.nonCompliantDeviceCount
        ErrorDeviceCount = $summary.errorDeviceCount
        ConflictDeviceCount = $summary.conflictDeviceCount
        Recomendacao = if ($summary.errorDeviceCount -gt 0) { 'Prioridade: investigar erros de avaliação.' } elseif ($summary.conflictDeviceCount -gt 0) { 'Revisar conflito entre políticas.' } elseif ($summary.nonCompliantDeviceCount -gt 0) { 'Remediar dispositivos não conformes.' } else { 'Sem alerta inicial.' }
        Causa = "NaoConformes=$($summary.nonCompliantDeviceCount); Erros=$($summary.errorDeviceCount); Conflitos=$($summary.conflictDeviceCount)"
        Solucao = 'Abrir o detalhamento por dispositivo e revisar política, atribuição, plataforma, período de carência e configuração.'
        Documentacao = 'https://learn.microsoft.com/graph/api/intune-deviceconfig-devicecompliancesettingstate-list'
    })

    $states = Invoke-GraphPagedRequest -Uri "https://graph.microsoft.com/v1.0/deviceManagement/deviceCompliancePolicySettingStateSummaries/$($summary.id)/deviceComplianceSettingStates"
    foreach ($state in $states) {
        $detailRows.Add([pscustomobject]@{
            SummaryId = $summary.id
            SettingName = $state.settingName
            DeviceId = $state.deviceId
            DeviceName = $state.deviceName
            DeviceModel = $state.deviceModel
            UserId = $state.userId
            UserPrincipalName = $state.userPrincipalName
            State = $state.state
            GracePeriodExpirationUTC = $state.complianceGracePeriodExpirationDateTime
            Causa = "Estado retornado: $($state.state)"
            Solucao = 'Validar a configuração de compliance e o período de carência do dispositivo.'
        })
    }
}

Export-GraphCsv -Data $summaryRows.ToArray() -Path (Join-Path $OutputDirectory 'intune-compliance-resumo.csv')
Export-GraphCsv -Data $detailRows.ToArray() -Path (Join-Path $OutputDirectory 'intune-compliance-detalhado.csv')
