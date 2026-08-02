param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'output')
)

. (Join-Path $PSScriptRoot '..\_Common\GraphHelpers.ps1')
Connect-GraphForScopes -Scopes @('Organization.Read.All','Directory.Read.All','User.Read.All','Group.Read.All')

$organization = (Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/organization?$select=id,displayName,onPremisesSyncEnabled,onPremisesLastSyncDateTime,verifiedDomains')[0]
$users = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/users?$select=id,onPremisesSyncEnabled&$top=999'
$groups = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/groups?$select=id,onPremisesSyncEnabled&$top=999'
$lastSync = if ($organization.onPremisesLastSyncDateTime) { [datetime]$organization.onPremisesLastSyncDateTime } else { $null }
$hoursSinceSync = if ($lastSync) { [math]::Round(((Get-Date).ToUniversalTime() - $lastSync.ToUniversalTime()).TotalHours, 2) } else { $null }

$syncFeatures = $null
try {
    $syncFeatures = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/beta/directory/onPremisesSynchronization'
}
catch {
    Write-Warning "Não foi possível coletar recursos beta de sincronização: $($_.Exception.Message)"
}

$result = [pscustomobject]@{
    TenantId = $organization.id
    Organizacao = $organization.displayName
    SincronizacaoHabilitada = $organization.onPremisesSyncEnabled
    UltimaSincronizacaoUTC = $organization.onPremisesLastSyncDateTime
    HorasDesdeUltimaSincronizacao = $hoursSinceSync
    UsuariosSincronizados = @($users | Where-Object onPremisesSyncEnabled).Count
    GruposSincronizados = @($groups | Where-Object onPremisesSyncEnabled).Count
    DominiosVerificados = ($organization.verifiedDomains | ForEach-Object { $_.name }) -join '; '
    RecursosBetaSincronizacao = ConvertTo-CompactJson $syncFeatures
    Recomendacao = if ($hoursSinceSync -and $hoursSinceSync -gt 24) { 'Prioridade: investigar atraso de sincronização.' } elseif (-not $organization.onPremisesSyncEnabled) { 'Validar se a ausência de sincronização é intencional.' } else { 'Manter monitoramento da última sincronização.' }
    Causa = if ($hoursSinceSync -and $hoursSinceSync -gt 24) { 'A última sincronização registrada ocorreu há mais de 24 horas.' } else { 'Estado calculado pelo objeto organization.' }
    Solucao = 'Validar serviço de sincronização, conectores, staging mode, exportações, conflitos e Password Hash Sync no servidor responsável.'
    Documentacao = 'https://learn.microsoft.com/graph/api/resources/organization'
}

Export-GraphCsv -Data @($result) -Path (Join-Path $OutputDirectory 'entra-connect-sync.csv')
