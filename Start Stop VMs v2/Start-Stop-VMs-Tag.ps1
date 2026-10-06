<#
.SYNOPSIS
    Liga ou desaloca VMs do Azure selecionadas por TAG, em uma ou mais assinaturas.

.DESCRIPTION
    Runbook para Azure Automation com Runtime Environment PowerShell 7.4 ou superior.

    O que ele faz, na ordem:
      1. Autentica com a System Assigned Managed Identity do Automation Account.
      2. Consulta o Azure Resource Graph para achar as VMs que têm a TAG informada.
      3. Confere o estado real de cada VM no provedor de Compute antes de agir.
      4. Liga (start) ou desaloca (stop) somente as VMs que precisam mudar de estado.
      5. Escreve uma linha de log por VM e um resumo em JSON no final.

    Módulos usados: Az.Accounts, Az.Compute e Az.ResourceGraph.
    Não existe credencial, segredo ou ID de assinatura fixo no código.

.PARAMETER Action
    start ou stop. O stop sempre desaloca a VM (Stopped (deallocated)).

.PARAMETER TagName
    Nome da TAG, escrito exatamente como está nos recursos. Exemplo: AutoStartStop

.PARAMETER TagValue
    Valor da TAG. Exemplo: business-hours

.PARAMETER SubscriptionIds
    Opcional. IDs de assinatura separados por vírgula.
    Vazio = todas as assinaturas habilitadas que a Managed Identity enxerga (Get-AzSubscription).

.PARAMETER WaitForCompletion
    false (padrão): dispara a operação em cada VM e segue para a próxima.
    true: espera cada VM terminar antes de seguir. Mais lento, porém o log traz o resultado final.

.PARAMETER DryRun
    true: só mostra o que seria feito. Nenhuma VM é alterada.

.NOTES
    Repositório: https://github.com/lfrleite/Ruiz-Online/tree/main/Start%20Stop%20VMs%20v2
#>

param(
    [Parameter(Mandatory = $true)]
    [string] $Action,

    [Parameter(Mandatory = $true)]
    [string] $TagName,

    [Parameter(Mandatory = $true)]
    [string] $TagValue,

    [Parameter(Mandatory = $false)]
    [string] $SubscriptionIds = '',

    [Parameter(Mandatory = $false)]
    [bool] $WaitForCompletion = $false,

    [Parameter(Mandatory = $false)]
    [bool] $DryRun = $false
)

$ErrorActionPreference = 'Stop'

# O sandbox do Azure Automation roda em UTC. O log deixa isso explícito no carimbo de hora.
function Write-Log {
    param(
        [string] $Level,
        [string] $Message
    )

    $line = '{0} [{1}] {2}' -f (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ'), $Level, $Message

    switch ($Level) {
        'WARN'  { Write-Warning -Message $line }
        'ERROR' { Write-Error -Message $line -ErrorAction Continue }
        default { Write-Output $line }
    }
}

# ---------------------------------------------------------------------------
# 1. Validação dos parâmetros
#    O Azure Automation só entende tipo, nome, obrigatoriedade e valor padrão.
#    ValidateSet e afins são ignorados, então a validação é feita aqui.
# ---------------------------------------------------------------------------
$Action = "$Action".Trim().ToLowerInvariant()
if ($Action -notin @('start', 'stop')) {
    throw "Parâmetro Action inválido: '$Action'. Use start ou stop."
}

$TagName  = "$TagName".Trim()
$TagValue = "$TagValue".Trim()

# TagName e TagValue entram no texto da consulta KQL. Só passa o que não quebra a consulta.
if ($TagName -notmatch '^[A-Za-z0-9_.\-]{1,128}$') {
    throw "Parâmetro TagName inválido: '$TagName'. Use apenas letras, números, ponto, hífen e sublinhado."
}
if ($TagValue -notmatch '^[A-Za-z0-9_.:\-/ ]{1,256}$') {
    throw "Parâmetro TagValue inválido: '$TagValue'. Use apenas letras, números, espaço, ponto, dois-pontos, barra, hífen e sublinhado."
}

$subscriptionList = @()
if (-not [string]::IsNullOrWhiteSpace($SubscriptionIds)) {
    $subscriptionList = @(
        $SubscriptionIds.Split(',') |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_ -ne '' }
    )
    foreach ($subscriptionId in $subscriptionList) {
        if ($subscriptionId -notmatch '^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$') {
            throw "ID de assinatura inválido em SubscriptionIds: '$subscriptionId'."
        }
    }
}

# ---------------------------------------------------------------------------
# 2. Autenticação com a System Assigned Managed Identity
# ---------------------------------------------------------------------------
try {
    # Garante que o runbook não herda o contexto de outro job no mesmo sandbox.
    Disable-AzContextAutosave -Scope Process | Out-Null
    $azContext = (Connect-AzAccount -Identity).Context
}
catch {
    throw "Falha ao autenticar com a Managed Identity do Automation Account: $($_.Exception.Message)"
}

if (-not (Get-Command -Name Search-AzGraph -ErrorAction SilentlyContinue)) {
    throw 'O cmdlet Search-AzGraph não existe neste Runtime Environment. Adicione o pacote Az.ResourceGraph e execute de novo.'
}

# Sem SubscriptionIds, o escopo é a lista de assinaturas que a identidade enxerga.
# A lista vai explícita no -Subscription porque, sem esse parâmetro, o Search-AzGraph
# consulta somente as assinaturas do contexto padrão.
if ($subscriptionList.Count -gt 0) {
    $scopeText = $subscriptionList -join ', '
}
else {
    try {
        $subscriptionList = @(
            Get-AzSubscription -DefaultProfile $azContext |
                Where-Object { $_.State -eq 'Enabled' } |
                ForEach-Object { $_.Id } |
                Select-Object -Unique
        )
    }
    catch {
        throw "Falha ao listar as assinaturas visíveis para a Managed Identity: $($_.Exception.Message)"
    }

    if ($subscriptionList.Count -eq 0) {
        throw 'A Managed Identity não enxerga nenhuma assinatura habilitada. Confira a atribuição da role e aguarde a propagação.'
    }

    $scopeText = "todas as assinaturas visíveis para a identidade ($($subscriptionList.Count))"
}

Write-Log -Level 'INFO' -Message "Início. Action=$Action; TAG $TagName=$TagValue; Escopo=$scopeText; WaitForCompletion=$WaitForCompletion; DryRun=$DryRun"

# ---------------------------------------------------------------------------
# 3. Descoberta das VMs pelo Azure Resource Graph
#    A coluna id precisa estar no project para o Resource Graph devolver o SkipToken.
# ---------------------------------------------------------------------------
$query = @"
resources
| where type =~ 'microsoft.compute/virtualmachines'
| where tags['$TagName'] =~ '$TagValue'
| project id, name, resourceGroup, subscriptionId, location, powerState = tostring(properties.extended.instanceView.powerState.code)
| order by id asc
"@

$vms = [System.Collections.Generic.List[object]]::new()
$skipToken = $null

try {
    do {
        $graphParams = @{
            Query          = $query
            Subscription   = $subscriptionList
            First          = 1000
            DefaultProfile = $azContext
        }
        if ($skipToken) { $graphParams['SkipToken'] = $skipToken }

        $page = Search-AzGraph @graphParams

        if ($null -ne $page -and $null -ne $page.Data) {
            foreach ($row in $page.Data) { $vms.Add($row) }
        }
        $skipToken = if ($null -ne $page) { $page.SkipToken } else { $null }
    } while ($skipToken)
}
catch {
    throw "Falha na consulta ao Azure Resource Graph: $($_.Exception.Message)"
}

Write-Log -Level 'INFO' -Message "VMs encontradas com a TAG: $($vms.Count)"

$summary = [ordered]@{
    action    = $Action
    tagName   = $TagName
    tagValue  = $TagValue
    dryRun    = $DryRun
    found     = $vms.Count
    requested = 0
    skipped   = 0
    simulated = 0
    failed    = 0
}

if ($vms.Count -eq 0) {
    Write-Log -Level 'WARN' -Message 'Nenhuma VM encontrada. Confira o nome da TAG, o valor e se a role da Managed Identity alcança as VMs.'
    Write-Output ('RESUMO ' + ($summary | ConvertTo-Json -Compress))
    return
}

# Estados em que a VM já está onde deveria (ou a caminho) para cada ação.
$alreadyDone = @{
    start = @('PowerState/running', 'PowerState/starting')
    stop  = @('PowerState/deallocated', 'PowerState/deallocating')
}

# ---------------------------------------------------------------------------
# 4. Ação por assinatura
#    O Resource Graph monta a lista. O estado que decide a ação vem do Get-AzVM -Status,
#    porque o Resource Graph é eventualmente consistente.
# ---------------------------------------------------------------------------
foreach ($group in ($vms | Group-Object -Property subscriptionId)) {

    try {
        $subContext = Set-AzContext -Subscription $group.Name -DefaultProfile $azContext
    }
    catch {
        $summary.failed += $group.Count
        Write-Log -Level 'ERROR' -Message "Assinatura $($group.Name): não foi possível definir o contexto. $($group.Count) VM(s) não tratada(s). Erro: $($_.Exception.Message)"
        continue
    }

    foreach ($vm in $group.Group) {

        $vmLabel = "$($vm.subscriptionId)/$($vm.resourceGroup)/$($vm.name)"

        try {
            $instanceView = Get-AzVM -ResourceGroupName $vm.resourceGroup -Name $vm.name -Status -DefaultProfile $subContext
            $powerState = ($instanceView.Statuses |
                    Where-Object { $_.Code -like 'PowerState/*' } |
                    Select-Object -First 1).Code

            if (-not $powerState) { $powerState = 'PowerState/unknown' }

            if ($powerState -in $alreadyDone[$Action]) {
                $summary.skipped++
                Write-Log -Level 'INFO' -Message "PULADA  $vmLabel | estado atual: $powerState | nada a fazer para $Action"
                continue
            }

            if ($DryRun) {
                $summary.simulated++
                Write-Log -Level 'INFO' -Message "DRYRUN  $vmLabel | estado atual: $powerState | seria executado: $Action"
                continue
            }

            $operationParams = @{
                ResourceGroupName = $vm.resourceGroup
                Name              = $vm.name
                DefaultProfile    = $subContext
            }
            if (-not $WaitForCompletion) { $operationParams['NoWait'] = $true }

            if ($Action -eq 'start') {
                $result = Start-AzVM @operationParams
            }
            else {
                # Sem -StayProvisioned o Stop-AzVM desaloca a VM. -Force evita o pedido de confirmação.
                $result = Stop-AzVM @operationParams -Force
            }

            $summary.requested++
            if ($WaitForCompletion) {
                Write-Log -Level 'INFO' -Message "FEITO   $vmLabel | estado anterior: $powerState | $Action concluído com status: $($result.Status)"
            }
            else {
                Write-Log -Level 'INFO' -Message "ENVIADO $vmLabel | estado anterior: $powerState | $Action solicitado sem aguardar o término"
            }
        }
        catch {
            $summary.failed++
            Write-Log -Level 'ERROR' -Message "FALHA   $vmLabel | $Action não executado. Erro: $($_.Exception.Message)"
        }
    }
}

# ---------------------------------------------------------------------------
# 5. Resumo
#    A linha em JSON facilita a consulta no Log Analytics.
#    Se alguma VM falhou, o job termina como Failed para o alerta pegar.
# ---------------------------------------------------------------------------
Write-Output ('RESUMO ' + ($summary | ConvertTo-Json -Compress))

if ($summary.failed -gt 0) {
    throw "Execução terminou com $($summary.failed) falha(s). Veja as linhas FALHA no log do job."
}

Write-Log -Level 'INFO' -Message 'Fim sem falhas.'
