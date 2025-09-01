param (
    [Parameter(Mandatory)] [String]$TenantId,
    [Parameter(Mandatory)] [String]$Chamado,
    [Parameter(Mandatory)] [String]$Solicitante,
    [Parameter(Mandatory)] [String]$Excluir
)
Connect-AzAccount -TenantId $TenantId
$Query = Search-AzGraph -Query "
    resources
    | where type == 'microsoft.compute/snapshots'
    | where isnotnull(tags.Chamado)
    | where tags.Chamado == '$Chamado'
    | where isnotnull(tags.Solicitante)
    | where tags.Solicitante == '$Solicitante'
    | where isnotnull(tags.['Excluir em'])
    | where tags.['Excluir em'] == '$Excluir'
    | project subscriptionId, location, resourceGroup, name, chamado = tags.Chamado, Solicitante = tags.Solicitante, excluir = tags.['Excluir em']"
# Exibe uma lista de snapshots que serão removidos
Write-Host "Os seguintes snapshots serão removidos:"
foreach ($Snapshot in $Query) {
    Write-Host "- $($Snapshot.name)"
}
# Solicita a confirmação do usuário antes de continuar
$Choice = Read-Host "Deseja continuar com a remoção dos snapshots listados acima? (S/N)"
if ($Choice -ne "S") {
    Write-Host "A remoção dos snapshots foi cancelada pelo usuário."
    exit
}
foreach ($SnapshotName in $Query) {
## Se o ID de assinatura do disco for diferente da assinatura atual, altere a assinatura
    if ($SnapshotName.subscriptionId -ne (Get-AzContext).Subscription.Id) {
        Select-AzSubscription -SubscriptionId $SnapshotName.subscriptionId -TenantId $TenantId | Out-Null
    }
    try {
        Remove-AzSnapshot $SnapshotName.resourceGroup -SnapshotName $SnapshotName.name -force
    } catch {
        $Choice = Read-Host "Um erro ocorreu ao excluir o snapshot, $($Disk.DiskName): $($_.Exception.Message)
        Deseja continuar? (S/N)"
        if ($Choice -ne "S") { exit }
    }
}
