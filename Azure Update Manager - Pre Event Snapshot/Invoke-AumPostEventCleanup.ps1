<#
.SYNOPSIS
    Post-event do Azure Update Manager: remove os snapshots vencidos que foram criados
    pelo runbook de pre-event.

.DESCRIPTION
    Runbook PowerShell 7.4 para Azure Automation, disparado por webhook a partir de uma
    Event Subscription (Post Maintenance Event) da maintenance configuration.

    Ele NAO apaga os snapshots da execucao que acabou de terminar. So entram na lista os
    snapshots com a TAG CriadoPor = aum-pre-event cuja data em "Excluir em" ja passou.

    Por padrao roda em modo relatorio (ReportOnly = $true) e apenas lista o que apagaria.

.PARAMETER WebhookData
    Objeto entregue pelo webhook do Azure Automation. O evento vem em RequestBody.

.PARAMETER SnapshotResourceGroupName
    Resource group onde o runbook de pre-event grava os snapshots.

.PARAMETER ReportOnly
    Quando $true, so lista os snapshots vencidos. Quando $false, apaga.

.NOTES
    Requisitos: runtime environment PowerShell 7.4 com o pacote Az.
    Autenticacao por Managed Identity. Nenhuma credencial no codigo.
#>

param
(
    [Parameter(Mandatory = $false)]
    [object] $WebhookData,

    [Parameter(Mandatory = $false)]
    [string] $SnapshotResourceGroupName = "rg-aum-snap-lab-wus2-001",

    [Parameter(Mandatory = $false)]
    [bool] $ReportOnly = $true
)

$ErrorActionPreference = "Stop"

$postEventType = "Microsoft.Maintenance.PostMaintenanceEvent"

function Write-Log {
    param([string] $Message)
    Write-Output ("{0:yyyy-MM-dd HH:mm:ss}Z  {1}" -f (Get-Date).ToUniversalTime(), $Message)
}

if ($null -eq $WebhookData) {
    throw "WebhookData vazio. Este runbook so faz sentido quando disparado pelo webhook."
}

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

if ($eventType -ne $postEventType) {
    Write-Log "Evento '$eventType' ignorado. Este runbook so trata $postEventType."
    return
}

$data = $evt.data
$runId = (([string] $data.CorrelationId) -split "/")[-1]
# @($null) tem um elemento. O filtro descarta nulos e qualquer valor que nao seja um GUID.
$resourceSubscriptionIds = @($data.ResourceSubscriptionIds | Where-Object { $_ -and ([string] $_) -match '^[0-9a-f-]{36}$' })

Write-Log "Execucao (run ID): $runId"
Write-Log "Status informado pela janela: $($data.Status)"
Write-Log "Modo: $(if ($ReportOnly) { 'relatorio (nada sera apagado)' } else { 'exclusao' })"

if ($resourceSubscriptionIds.Count -eq 0) {
    Write-Log "O evento nao trouxe nenhuma assinatura valida em ResourceSubscriptionIds. Nada a fazer."
    return
}

Disable-AzContextAutosave -Scope Process | Out-Null
Connect-AzAccount -Identity | Out-Null
Write-Log "Autenticado com a Managed Identity do Automation Account."

$today = (Get-Date).ToUniversalTime().Date
$expired = 0
$removed = 0
$errors = 0

foreach ($subscriptionId in $resourceSubscriptionIds) {
    try {
        Set-AzContext -Subscription $subscriptionId | Out-Null
        $snapshots = @(Get-AzSnapshot -ResourceGroupName $SnapshotResourceGroupName)
    }
    catch {
        Write-Log "Assinatura ${subscriptionId}: nao foi possivel listar os snapshots. $($_.Exception.Message)"
        $errors++
        continue
    }

    foreach ($snapshot in $snapshots) {
        $tags = $snapshot.Tags
        if ($null -eq $tags) { continue }
        if ($tags["CriadoPor"] -ne "aum-pre-event") { continue }

        # Nunca toca nos snapshots da execucao que acabou de terminar.
        if ($tags["PatchRunId"] -eq $runId) { continue }

        $deleteAfterText = $tags["Excluir em"]
        if ([string]::IsNullOrWhiteSpace($deleteAfterText)) { continue }

        $deleteAfter = [datetime]::MinValue
        $parsed = [datetime]::TryParseExact(
            $deleteAfterText,
            "dd-MM-yyyy",
            [System.Globalization.CultureInfo]::InvariantCulture,
            [System.Globalization.DateTimeStyles]::None,
            [ref] $deleteAfter)

        if (-not $parsed) {
            Write-Log "  $($snapshot.Name): TAG 'Excluir em' com valor invalido ($deleteAfterText). Ignorado."
            continue
        }

        if ($deleteAfter -ge $today) { continue }

        $expired++

        if ($ReportOnly) {
            Write-Log "  $($snapshot.Name): vencido em $deleteAfterText. Seria apagado."
            continue
        }

        try {
            Remove-AzSnapshot `
                -ResourceGroupName $SnapshotResourceGroupName `
                -SnapshotName $snapshot.Name `
                -Force | Out-Null
            Write-Log "  $($snapshot.Name): apagado (vencido em $deleteAfterText)."
            $removed++
        }
        catch {
            Write-Log "  $($snapshot.Name): FALHA ao apagar. $($_.Exception.Message)"
            $errors++
        }
    }
}

Write-Log "Concluido. Vencidos: $expired. Apagados: $removed. Erros: $errors."

if ($errors -gt 0) {
    throw "$errors erro(s) durante a limpeza. Veja o log acima."
}
