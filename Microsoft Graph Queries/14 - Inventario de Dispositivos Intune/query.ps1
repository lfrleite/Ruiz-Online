param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'output')
)

. (Join-Path $PSScriptRoot '..\_Common\GraphHelpers.ps1')
Connect-GraphForScopes -Scopes @('DeviceManagementManagedDevices.Read.All')

$devices = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?$top=999'

$rows = foreach ($device in $devices) {
    [pscustomobject]@{
        DeviceId = $device.id
        DeviceName = $device.deviceName
        AzureADDeviceId = $device.azureADDeviceId
        UserPrincipalName = $device.userPrincipalName
        OperatingSystem = $device.operatingSystem
        OSVersion = $device.osVersion
        Manufacturer = $device.manufacturer
        Model = $device.model
        SerialNumber = $device.serialNumber
        Ownership = $device.managedDeviceOwnerType
        ManagementAgent = $device.managementAgent
        EnrollmentType = $device.deviceEnrollmentType
        ComplianceState = $device.complianceState
        LastSyncDateTime = $device.lastSyncDateTime
        Encrypted = $device.isEncrypted
        JailBroken = $device.jailBroken
        PartnerThreatState = $device.partnerReportedThreatState
        DeviceCategory = $device.deviceCategoryDisplayName
        Recomendacao = if ($device.complianceState -ne 'compliant') { 'Investigar dispositivo não conforme ou sem avaliação.' } elseif (-not $device.isEncrypted) { 'Validar política e estado de criptografia.' } else { 'Sem alerta inicial.' }
        Causa = "Compliance=$($device.complianceState); Encrypted=$($device.isEncrypted); LastSync=$($device.lastSyncDateTime)"
        Solucao = 'Correlacionar com políticas, configurações não conformes, último check-in e fluxo de enrollment.'
        Documentacao = 'https://learn.microsoft.com/graph/api/intune-devices-manageddevice-list'
    }
}

Export-GraphCsv -Data @($rows) -Path (Join-Path $OutputDirectory 'intune-managed-devices.csv')
