param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'output')
)

. (Join-Path $PSScriptRoot '..\_Common\GraphHelpers.ps1')
Connect-GraphForScopes -Scopes @(
    'Organization.Read.All',
    'User.Read.All',
    'Group.Read.All',
    'Device.Read.All',
    'DeviceManagementManagedDevices.Read.All'
)

$headers = @{ ConsistencyLevel = 'eventual' }

$organization = (Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/organization?$select=id,displayName,onPremisesSyncEnabled,onPremisesLastSyncDateTime,verifiedDomains')[0]
$users = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/users?$select=id,userType,accountEnabled,onPremisesSyncEnabled&$top=999' -Headers $headers
$groups = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/groups?$select=id,groupTypes,securityEnabled,mailEnabled,membershipRule,membershipRuleProcessingState&$top=999' -Headers $headers
$devices = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/devices?$select=id,accountEnabled,operatingSystem,trustType,approximateLastSignInDateTime&$top=999' -Headers $headers
$managedDevices = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/deviceManagement/managedDevices?$select=id,operatingSystem,complianceState,lastSyncDateTime&$top=999'

$entraDevices = $devices.Count
$intuneDevices = $managedDevices.Count
$deviceDifference = $entraDevices - $intuneDevices

$result = [pscustomobject]@{
    DataColetaUTC = (Get-Date).ToUniversalTime()
    Organizacao = $organization.displayName
    TenantId = $organization.id
    SincronizacaoOnPremisesHabilitada = $organization.onPremisesSyncEnabled
    UltimaSincronizacaoOnPremisesUTC = $organization.onPremisesLastSyncDateTime
    DominiosVerificados = ($organization.verifiedDomains | ForEach-Object { $_.name }) -join '; '
    TotalUsuarios = $users.Count
    UsuariosHabilitados = @($users | Where-Object accountEnabled).Count
    UsuariosDesabilitados = @($users | Where-Object { -not $_.accountEnabled }).Count
    UsuariosMembros = @($users | Where-Object userType -eq 'Member').Count
    UsuariosConvidados = @($users | Where-Object userType -eq 'Guest').Count
    UsuariosSincronizados = @($users | Where-Object onPremisesSyncEnabled).Count
    TotalGrupos = $groups.Count
    GruposMicrosoft365 = @($groups | Where-Object { $_.groupTypes -contains 'Unified' }).Count
    GruposSeguranca = @($groups | Where-Object securityEnabled).Count
    GruposDinamicos = @($groups | Where-Object { $_.groupTypes -contains 'DynamicMembership' }).Count
    TotalDispositivosEntra = $entraDevices
    TotalDispositivosIntune = $intuneDevices
    DiferencaEntraIntune = $deviceDifference
    DispositivosNaoConformesIntune = @($managedDevices | Where-Object complianceState -ne 'compliant').Count
    Recomendacao = if ($deviceDifference -ne 0) { 'Reconciliar inventarios do Microsoft Entra ID e Intune.' } else { 'Manter acompanhamento recorrente dos inventarios.' }
    Causa = if ($deviceDifference -ne 0) { 'A quantidade de dispositivos registrados no Entra ID difere da quantidade gerenciada pelo Intune.' } else { 'Nenhuma divergencia quantitativa identificada nesta coleta.' }
    Solucao = 'Validar dispositivos duplicados, desabilitados, nao gerenciados, obsoletos e fluxos de enrollment.'
    Documentacao = 'https://learn.microsoft.com/graph/api/resources/organization'
}

Export-GraphCsv -Data @($result) -Path (Join-Path $OutputDirectory 'visao-geral-tenant.csv')
