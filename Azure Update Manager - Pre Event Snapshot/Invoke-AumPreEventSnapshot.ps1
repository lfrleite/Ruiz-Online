<#
.SYNOPSIS
    Pre-event do Azure Update Manager: cria snapshot incremental de todos os discos
    das VMs que fazem parte da janela de manutenção que está para começar.

.DESCRIPTION
    Runbook PowerShell 7.4 para Azure Automation, disparado por webhook a partir de uma
    Event Subscription (Pre Maintenance Event) da maintenance configuration.

    Fluxo:
      1. Lê o evento entregue pelo Event Grid no WebhookData e valida o formato dos IDs.
      2. Ignora qualquer evento que não seja Microsoft.Maintenance.PreMaintenanceEvent.
      3. Autentica com a Managed Identity do Automation Account.
      4. Consulta o Azure Resource Graph para descobrir as VMs da execução (CorrelationId).
      5. Cria um snapshot incremental por disco, com TAGs de rastreio.
      6. Se algo falhar, se nenhuma VM for encontrada ou se o tempo acabar, cancela a
         execução da janela (opcional).

    O nome do snapshot é determinístico (disco + ID da execução). Se o Event Grid entregar
    o mesmo evento duas vezes, a segunda execução encontra os snapshots e não duplica nada.

.PARAMETER WebhookData
    Objeto entregue pelo webhook do Azure Automation. O evento vem em RequestBody.

.PARAMETER SnapshotResourceGroupName
    Resource group que recebe os snapshots. Precisa existir na mesma assinatura dos discos.

.PARAMETER RetentionDays
    Dias até a data gravada na TAG "Excluir em".

.PARAMETER CancelOnFailure
    Quando $true, cancela a execução da janela se algum snapshot falhar, se nenhuma VM
    for encontrada ou se o tempo acabar.

.PARAMETER SafetyMarginMinutes
    Minutos antes do início da janela em que o runbook para de criar snapshot e decide.
    O cancelamento precisa ser chamado pelo menos 10 minutos antes do início da janela.

.NOTES
    Requisitos: runtime environment PowerShell 7.4 com os pacotes Az e Az.ResourceGraph.
    Nenhuma credencial fica no código. A autenticação é feita por Managed Identity.
#>

param
(
    [Parameter(Mandatory = $false)]
    [object] $WebhookData,

    [Parameter(Mandatory = $false)]
    [string] $SnapshotResourceGroupName = "rg-aum-snap-lab-wus2-001",

    [Parameter(Mandatory = $false)]
    [int] $RetentionDays = 7,

    [Parameter(Mandatory = $false)]
    [bool] $CancelOnFailure = $true,

    [Parameter(Mandatory = $false)]
    [int] $SafetyMarginMinutes = 12
)

$ErrorActionPreference = "Stop"

$preEventType = "Microsoft.Maintenance.PreMaintenanceEvent"
$cancelApiVersion = "2023-09-01-preview"
$graphAttempts = 3
$graphRetrySeconds = 30

# Formato esperado do CorrelationId: o ID ARM da execucao (applyUpdates) de uma maintenance configuration.
# O valor vem de fora, pelo webhook, e e usado em uma consulta e em uma chamada PUT. Por isso e validado.
$correlationIdPattern = '^/subscriptions/[0-9a-f-]{36}/resourceGroups/[^/]+/providers/Microsoft\.Maintenance/maintenanceConfigurations/[^/]+/providers/Microsoft\.Maintenance/applyUpdates/[a-z0-9-]{1,40}$'
$subscriptionIdPattern = '^[0-9a-f-]{36}$'

function Write-Log {
    param([string] $Message)
    Write-Output ("{0:yyyy-MM-dd HH:mm:ss}Z  {1}" -f (Get-Date).ToUniversalTime(), $Message)
}

function Stop-MaintenanceRun {
    param(
        [string] $CorrelationId,
        [string] $Reason
    )

    Write-Log "Cancelando a execucao da janela. Motivo: $Reason"

    $payload = '{ "properties": { "status": "Cancel" } }'
    $response = Invoke-AzRestMethod `
        -Path "$CorrelationId`?api-version=$cancelApiVersion" `
        -Method PUT `
        -Payload $payload

    if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 201) {
        Write-Log "Cancelamento aceito (HTTP $($response.StatusCode))."
    }
    else {
        Write-Log "O cancelamento NAO foi aceito (HTTP $($response.StatusCode)). Resposta: $($response.Content)"
        Write-Log "Sem cancelamento, a instalacao dos updates segue no horario da janela."
    }
}

# ---------------------------------------------------------------------------
# 1. Leitura e validacao do evento
# ---------------------------------------------------------------------------

if ($null -eq $WebhookData) {
    throw "WebhookData vazio. Este runbook so faz sentido quando disparado pelo webhook."
}

# No Test pane o WebhookData chega como texto. Pelo webhook chega como objeto.
if ($WebhookData -is [string]) {
    $WebhookData = ConvertFrom-Json -InputObject $WebhookData
}

$requestBody = $WebhookData.RequestBody
if ($null -eq $requestBody -or [string]::IsNullOrWhiteSpace([string] $requestBody)) {
    throw "RequestBody vazio. O Event Grid nao enviou nenhum evento neste disparo."
}

if ($requestBody -is [string]) {
    $notificationPayload = ConvertFrom-Json -InputObject $requestBody
}
else {
    $notificationPayload = $requestBody
}

$evt = @($notificationPayload)[0]
$eventType = $evt.eventType

if ($eventType -ne $preEventType) {
    Write-Log "Evento '$eventType' ignorado. Este runbook so trata $preEventType."
    return
}

$data = $evt.data
$correlationId = [string] $data.CorrelationId
$maintenanceConfigurationId = [string] $data.MaintenanceConfigurationId

if ($correlationId -notmatch $correlationIdPattern) {
    throw "CorrelationId ausente ou fora do formato esperado. Sem ele nao e possivel achar as VMs nem cancelar."
}

# @($null) tem um elemento. O filtro abaixo descarta nulos e qualquer valor que nao seja um GUID.
$resourceSubscriptionIds = @($data.ResourceSubscriptionIds | Where-Object { $_ -and ([string] $_) -match $subscriptionIdPattern })

if ($null -eq $data.StartDateTime) {
    throw "O evento nao trouxe StartDateTime. Sem o inicio da janela nao ha como calcular o limite."
}

$runId = ($correlationId -split "/")[-1]
$maintenanceConfigurationName = ($maintenanceConfigurationId -split "/")[-1]

# O ConvertFrom-Json do PowerShell 7 ja entrega datas ISO 8601 como DateTime.
# O cast abaixo funciona nos dois casos (texto ou DateTime).
$windowStart = ([datetime] $data.StartDateTime).ToUniversalTime()
$deadline = $windowStart.AddMinutes(-1 * $SafetyMarginMinutes)

Write-Log "Maintenance configuration: $maintenanceConfigurationName"
Write-Log "Execucao (run ID): $runId"
Write-Log "Inicio da janela (UTC): $($windowStart.ToString('yyyy-MM-dd HH:mm:ss'))"
Write-Log "Limite para terminar os snapshots (UTC): $($deadline.ToString('yyyy-MM-dd HH:mm:ss'))"

# ---------------------------------------------------------------------------
# 2. Autenticacao com Managed Identity
# ---------------------------------------------------------------------------

# Se a autenticacao falhar, o job termina aqui como Failed e nao existe como cancelar a janela.
Disable-AzContextAutosave -Scope Process | Out-Null
Connect-AzAccount -Identity | Out-Null
Write-Log "Autenticado com a Managed Identity do Automation Account."

# ---------------------------------------------------------------------------
# 3. Snapshots
# ---------------------------------------------------------------------------

$created = 0
$skipped = 0
$timedOut = $false
$failures = [System.Collections.Generic.List[string]]::new()

try {
    if ($resourceSubscriptionIds.Count -eq 0) {
        throw "o evento nao trouxe nenhuma assinatura valida em ResourceSubscriptionIds."
    }

    $argQuery = @"
maintenanceresources
| where type =~ 'microsoft.maintenance/applyupdates'
| where properties.correlationId =~ '$correlationId'
| where id has '/providers/microsoft.compute/virtualmachines/'
| project id, resourceId = tostring(properties.resourceId)
| order by id asc
"@

    Write-Log "Consultando o Resource Graph em $($resourceSubscriptionIds.Count) assinatura(s)."

    $allMachines = [System.Collections.ArrayList]@()

    for ($attempt = 1; $attempt -le $graphAttempts; $attempt++) {
        $allMachines.Clear()
        $skipToken = $null

        do {
            $result = Search-AzGraph -Query $argQuery -First 1000 -SkipToken $skipToken -Subscription $resourceSubscriptionIds
            $skipToken = $result.SkipToken
            foreach ($row in $result.Data) {
                [void] $allMachines.Add($row)
            }
        } while ($null -ne $skipToken -and $skipToken.Length -ne 0)

        if ($allMachines.Count -gt 0) {
            break
        }

        if ($attempt -lt $graphAttempts) {
            Write-Log "Nenhuma VM encontrada (tentativa $attempt de $graphAttempts). Nova consulta em $graphRetrySeconds segundos."
            Start-Sleep -Seconds $graphRetrySeconds
        }
    }

    # Lista vazia e tratada como falha: sem lista de VMs nao existe snapshot, e o patch nao deve seguir.
    # A causa mais comum e a identidade sem a role Reader no resource group das VMs.
    if ($allMachines.Count -eq 0) {
        throw "o Resource Graph nao devolveu nenhuma VM para esta execucao."
    }

    Write-Log "VMs na janela: $($allMachines.Count)"

    $currentSubscription = ""
    $deleteAfter = (Get-Date).ToUniversalTime().AddDays($RetentionDays).ToString("dd-MM-yyyy")

    # Nome de snapshot aceita ate 80 caracteres: "snap-" + nome do disco + "-" + run ID.
    $maxDiskNameLength = 80 - 6 - $runId.Length

    foreach ($machine in $allMachines) {
        if ((Get-Date).ToUniversalTime() -ge $deadline) {
            $timedOut = $true
            break
        }

        $vmId = [string] $machine.resourceId
        $vmParts = $vmId -split "/"
        $vmName = $vmId

        try {
            if ($vmParts.Count -lt 9) {
                throw "resourceId fora do formato esperado."
            }

            $subscriptionId = $vmParts[2]
            $vmResourceGroup = $vmParts[4]
            $vmName = $vmParts[8]

            if ($currentSubscription -ne $subscriptionId) {
                Set-AzContext -Subscription $subscriptionId | Out-Null
                $currentSubscription = $subscriptionId
            }

            $vm = Get-AzVM -ResourceGroupName $vmResourceGroup -Name $vmName

            $diskIds = [System.Collections.Generic.List[string]]::new()
            if ($vm.StorageProfile.OsDisk.ManagedDisk.Id) {
                $diskIds.Add($vm.StorageProfile.OsDisk.ManagedDisk.Id)
            }
            foreach ($dataDisk in $vm.StorageProfile.DataDisks) {
                if ($dataDisk.ManagedDisk.Id) {
                    $diskIds.Add($dataDisk.ManagedDisk.Id)
                }
            }

            if ($diskIds.Count -eq 0) {
                throw "nenhum managed disk encontrado na VM."
            }

            Write-Log "VM $vmName ($vmResourceGroup): $($diskIds.Count) disco(s)."

            foreach ($diskId in $diskIds) {
                if ((Get-Date).ToUniversalTime() -ge $deadline) {
                    $timedOut = $true
                    throw "tempo esgotado antes de terminar os snapshots."
                }

                $diskParts = $diskId -split "/"
                $diskResourceGroup = $diskParts[4]
                $diskName = $diskParts[8]

                $shortDiskName = $diskName
                if ($shortDiskName.Length -gt $maxDiskNameLength) {
                    $shortDiskName = $shortDiskName.Substring(0, $maxDiskNameLength)
                }
                $snapshotName = "snap-$shortDiskName-$runId"

                $existing = Get-AzSnapshot `
                    -ResourceGroupName $SnapshotResourceGroupName `
                    -SnapshotName $snapshotName `
                    -ErrorAction SilentlyContinue

                if ($existing) {
                    # O nome so prova que o snapshot existe. A origem prova que ele e deste disco.
                    # Dois discos com o mesmo nome em resource groups diferentes cairiam no mesmo nome.
                    if ($existing.CreationData.SourceResourceId -ne $diskId) {
                        throw "o nome $snapshotName ja esta em uso por um snapshot de outro disco."
                    }
                    if ($existing.ProvisioningState -ne "Succeeded") {
                        throw "o snapshot $snapshotName existe, mas esta em estado $($existing.ProvisioningState)."
                    }

                    Write-Log "  $snapshotName ja existe. Nada a fazer."
                    $skipped++
                    continue
                }

                $disk = Get-AzDisk -ResourceGroupName $diskResourceGroup -DiskName $diskName

                $tags = @{
                    "CriadoPor"   = "aum-pre-event"
                    "PatchRunId"  = $runId
                    "Maintenance" = $maintenanceConfigurationName
                    "VM"          = $vmName
                    "Disco"       = $diskName
                    "Chamado"     = "AUM-$runId"
                    "Solicitante" = "Azure Update Manager"
                    "Excluir em"  = $deleteAfter
                }

                $snapshotConfig = New-AzSnapshotConfig `
                    -SourceUri $disk.Id `
                    -Location $disk.Location `
                    -CreateOption Copy `
                    -Incremental `
                    -Tag $tags

                New-AzSnapshot `
                    -ResourceGroupName $SnapshotResourceGroupName `
                    -SnapshotName $snapshotName `
                    -Snapshot $snapshotConfig | Out-Null

                Write-Log "  $snapshotName criado."
                $created++
            }
        }
        catch {
            $message = "VM $vmName - $($_.Exception.Message)"
            Write-Log "  FALHA: $message"
            $failures.Add($message)
        }

        # Com o tempo esgotado nao adianta visitar as outras VMs. O que importa e cancelar logo.
        if ($timedOut) {
            break
        }
    }

    if ($timedOut) {
        throw "tempo esgotado antes de terminar os snapshots de todas as VMs."
    }

    if ($failures.Count -gt 0) {
        throw "$($failures.Count) VM(s) ficaram sem snapshot completo."
    }

    Write-Log "Concluido. Snapshots criados: $created. Ja existentes: $skipped."
}
catch {
    $failure = $_
    Write-Log "ERRO: $($failure.Exception.Message)"
    Write-Log "Snapshots criados ate aqui: $created. Ja existentes: $skipped. Falhas: $($failures.Count)."

    if ($CancelOnFailure) {
        try {
            Stop-MaintenanceRun -CorrelationId $correlationId -Reason $failure.Exception.Message
        }
        catch {
            Write-Log "Falha ao chamar a API de cancelamento: $($_.Exception.Message)"
        }
    }
    else {
        Write-Log "CancelOnFailure esta desligado. A instalacao dos updates segue no horario da janela."
    }

    # Faz o job terminar como Failed para aparecer no historico e nos alertas.
    throw $failure
}
