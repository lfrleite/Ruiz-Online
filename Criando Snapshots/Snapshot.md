### Execute o arquivo 'snapshot.ps1' incluindo os parâmetros -TenantId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" -RGSnapshots "nomedoRG":
```powershell
.\snapshot.ps1 -TenantId “xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx” -ResourceGroupName “nomedoRG“
```

```powershell
param (
    [Parameter(Mandatory = $true)] [String]$TenantId,
    [Parameter(Mandatory = $true)] [String]$RGSnapshots,
    [Parameter(Mandatory = $true)][ValidateSet("OS", "Data", "All")][String]$DiskTypeMode 
)
Connect-AzAccount -TenantId $TenantId

# Importar um arquivo CSV com o caminho ".\snapshot.csv" (Mesma pasta onde está localizado o arquivo 'snapshot.ps1')
# necessário ter duas colunas, uma com o nome da VM e outra com o ID da assinatura.
$VMsList = Import-Csv -Path ".\snapshot.csv" -Delimiter ";"

# Defina as Tags que serão aplicadas aos snapshots.
$Tags = @{
    Chamado      = "Ticket"
    Solicitante  = "Fulano da Silva"
    "Excluir em" = "01-12-2099"
}
$Choice = Read-Host "
VMs que serão realizadas os snapshots: $($VMsList.VM)
Tags: Chamado: $($Tags.Chamado), Solicitante: $($Tags.Solicitante), Excluir: $($Tags.'Excluir em')
Deseja continuar? (S/N)"
if ($Choice -ne "S") { exit }
$Disks = @()
foreach ($VM in $VMsList) {

    ## Não lista disco não gerenciado.
    $Query = Search-AzGraph -Query "
    Resources
    | where type == 'microsoft.compute/disks'
    | where tostring(split(managedBy, '/')[-1]) =~ '$($VM.VM)' and subscriptionId == '$($VM.SubscriptionId)'
    | extend OsDisk = iif(isnull(properties.osType), false, true)
    | project subscriptionId, OsDisk, location, resourceGroup, VMName = tostring(split(managedBy, '/')[-1]), DiskName = name, id"
    $Disks += $Query

    # Se a consulta não retornar resultados para a VM atual, exibe uma mensagem de erro e encerra o script.
    if ($Query.Count -eq 0) {
        Write-Host "Não foi encontrado a VM $($VM.VM) na assinatura $($VM.subscriptionId), favor inserir um arquivo csv válido." -ForegroundColor Red
        exit  
    }
}
    if ($DiskTypeMode -eq "OS") {
        $Disks = $Disks | Where-Object { $_.OsDisk -eq $true }
    }
    elseif ($DiskTypeMode -eq "Data") {
        $Disks = $Disks | Where-Object { $_.OsDisk -eq $false }
    }
$timestamp = Get-Date -f ddMMyyyy
foreach ($Disk in $Disks) {

    ## Se o ID de assinatura do disco for diferente da assinatura atual, o script altera a assinatura.
    if ($Disk.subscriptionId -ne (Get-AzContext).Subscription.Id) {
        Select-AzSubscription -SubscriptionId $Disk.subscriptionId -TenantId $TenantId | Out-Null
    }
    try {
        $Snapshotconfig = New-AzSnapshotConfig  -Location "$($Disk.location)" -SourceUri "$($Disk.id)" -AccountType Standard_LRS -CreateOption copy
        $SnapshotName = $Disk.DiskName + "_" + $timestamp
        $Resource = New-AzSnapshot -ResourceGroupName $RGSnapshots -Snapshot $Snapshotconfig -SnapshotName $SnapshotName
        New-AzTag -ResourceId $Resource.Id -Tag $Tags -ErrorAction Continue
        $Log = "Info: Foi criado o snapshot do disco: $($Disk.DiskName) na assinatura: $($Disk.subscriptionId) na data: $(Get-Date -f dd/MM/yyyy/HH:mm:ss)"
        $Log | Out-File -FilePath "snapshotlogs $($Disk.subscriptionId).log" -Append  
    }
    catch {
        $Log = "Erro: Não foi possível criar o snapshot do disco: $($Disk.DiskName) na assinatura: $($Disk.subscriptionId) na data: $(Get-Date -f dd/MM/yyyy/HH:mm:ss) - $($_.Exception.Message)"
        $Log | Out-File -FilePath "snapshotlogs $($Disk.subscriptionId).log" -Append
        $Choice = Read-Host "Um erro ocorreu ao criar o snapshot do disco, $($Disk.DiskName): $($_.Exception.Message)
        Deseja continuar? (S/N)"
        if ($Choice -ne "S") { exit }
    }
}
```
