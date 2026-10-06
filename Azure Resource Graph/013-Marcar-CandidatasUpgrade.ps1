<#
.SYNOPSIS
    Classifica as VMs por S.O. e situacao de suporte com o Azure Resource Graph,
    gera um CSV e, se solicitado, marca as candidatas a upgrade com uma TAG.

.DESCRIPTION
    Executa a consulta do arquivo 013-so-fim-de-suporte.kql com paginacao,
    exporta o resultado completo em CSV e lista as VMs com Candidata = Sim.
    Sem o parametro -Apply nada e alterado. Com -Apply, a TAG e aplicada com
    Update-AzTag em modo Merge, que preserva as TAGs existentes.
    A coluna TagUpgrade da consulta le a TAG UpgradeSO. Se voce trocar -TagName,
    troque tambem o nome da TAG dentro do arquivo .kql.

.EXAMPLE
    ./013-Marcar-CandidatasUpgrade.ps1
    Somente relatorio, em todas as assinaturas do contexto atual.

.EXAMPLE
    ./013-Marcar-CandidatasUpgrade.ps1 -ManagementGroup 'mg-lab' -Apply -WhatIf
    Mostra quais VMs receberiam a TAG, sem aplicar.

.EXAMPLE
    ./013-Marcar-CandidatasUpgrade.ps1 -Subscription '00000000-0000-0000-0000-000000000000' -Apply
    Aplica a TAG nas candidatas de uma assinatura.
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [string]$QueryFile = (Join-Path $PSScriptRoot '013-so-fim-de-suporte.kql'),
    [string[]]$Subscription,
    [string]$ManagementGroup,
    [string]$CsvPath = (Join-Path (Get-Location) '013-so-fim-de-suporte.csv'),
    [string]$TagName = 'UpgradeSO',
    [string]$TagValue = 'Candidata',
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'

foreach ($module in 'Az.Accounts', 'Az.ResourceGraph', 'Az.Resources') {
    if (-not (Get-Module -ListAvailable -Name $module)) {
        throw "Modulo $module nao encontrado. Instale com: Install-Module -Name $module -Scope CurrentUser"
    }
}

if (-not (Get-AzContext)) {
    throw 'Nenhuma sessao ativa no Azure. Execute Connect-AzAccount antes de rodar o script.'
}

if ($Subscription -and $ManagementGroup) {
    throw 'Informe -Subscription ou -ManagementGroup, nao os dois.'
}

if (-not (Test-Path -Path $QueryFile -PathType Leaf)) {
    throw "Arquivo de consulta nao encontrado: $QueryFile"
}

$query = Get-Content -Path $QueryFile -Raw

$scope = @{}
if ($ManagementGroup) {
    $scope.ManagementGroup = $ManagementGroup
}
elseif ($Subscription) {
    $scope.Subscription = $Subscription
}

# Paginacao: o Resource Graph devolve no maximo 1000 registros por chamada.
$rows = [System.Collections.Generic.List[object]]::new()
$skipToken = $null
do {
    $page = @{ Query = $query; First = 1000 }
    if ($skipToken) {
        $page.SkipToken = $skipToken
    }

    try {
        $response = Search-AzGraph @page @scope
    }
    catch {
        throw "Falha ao consultar o Resource Graph: $($_.Exception.Message)"
    }

    foreach ($row in $response.Data) {
        $rows.Add($row)
    }
    $skipToken = $response.SkipToken
} while ($skipToken)

# Sem a coluna id, ou com limit/take na consulta, o Resource Graph nao devolve skip token.
if ($rows.Count -eq 1000) {
    Write-Warning 'Vieram exatamente 1000 registros. Se o ambiente tem mais VMs, confira se a consulta projeta a coluna id e nao usa limit ou take.'
}

if ($rows.Count -eq 0) {
    Write-Warning 'A consulta nao retornou nenhuma VM. Confira o escopo e se a sua conta tem permissao de leitura.'
    return
}

$columns = 'name', 'resourceGroup', 'subscriptionId', 'location', 'SO', 'Situacao', 'Prioridade',
           'Candidata', 'Fonte', 'PowerState', 'osName', 'osVersion', 'imgOffer', 'imgSku', 'TagUpgrade', 'id'

$rows | Select-Object -Property $columns | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding utf8
Write-Host "VMs analisadas: $($rows.Count). CSV gravado em $CsvPath"

$rows | Group-Object -Property Prioridade | Sort-Object -Property Name |
    Select-Object -Property @{ Name = 'Prioridade'; Expression = { $_.Name } }, @{ Name = 'VMs'; Expression = { $_.Count } } |
    Format-Table -AutoSize | Out-Host

$candidates = @($rows | Where-Object { $_.Candidata -eq 'Sim' })
Write-Host "Candidatas a upgrade: $($candidates.Count)"

if (-not $Apply) {
    Write-Host 'Nenhuma TAG foi aplicada. Revise o CSV e rode de novo com -Apply (use -WhatIf para simular).'
    return
}

$tagged = 0
$skipped = 0
$failed = 0

foreach ($vm in $candidates) {
    if ($TagName -eq 'UpgradeSO' -and $vm.TagUpgrade -eq $TagValue) {
        $skipped++
        continue
    }

    if ($PSCmdlet.ShouldProcess($vm.name, "Aplicar TAG $TagName=$TagValue")) {
        try {
            Update-AzTag -ResourceId $vm.id -Tag @{ $TagName = $TagValue } -Operation Merge | Out-Null
            $tagged++
            Write-Host "TAG aplicada: $($vm.name) ($($vm.SO))"
        }
        catch {
            $failed++
            Write-Warning "Falha ao aplicar TAG em $($vm.name): $($_.Exception.Message)"
        }
    }
}

Write-Host "Resumo: $tagged marcadas, $skipped ja estavam marcadas, $failed com falha."

if ($failed -gt 0) {
    Write-Error "$failed VM(s) nao receberam a TAG. Veja os avisos acima." -ErrorAction Continue
    exit 1
}
