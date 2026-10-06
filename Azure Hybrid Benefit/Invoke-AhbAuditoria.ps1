#Requires -Version 7.2
#Requires -Modules Az.Accounts, Az.ResourceGraph, Az.Compute

<#
.SYNOPSIS
    Audita o Azure Hybrid Benefit nas VMs Windows e, opcionalmente, liga o beneficio nas VMs marcadas por TAG.

.DESCRIPTION
    1. Consulta o Azure Resource Graph e lista toda VM com S.O. Windows e o valor de licenseType.
    2. Busca a quantidade de vCPUs de cada tamanho de VM e estima os nucleos de licenca (minimo de 8 por VM).
    3. Exporta o resultado em CSV.
    4. Com -Aplicar, liga o Azure Hybrid Benefit (licenseType = Windows_Server) somente nas VMs que
       estao com o beneficio desligado E possuem a TAG de elegibilidade com o valor esperado.

    O script nao decide elegibilidade. Quem decide e a pessoa responsavel pelas licencas, e a decisao
    chega ate aqui pela TAG.

.PARAMETER SubscriptionId
    Uma ou mais assinaturas. Sem este parametro a consulta usa o escopo do tenant.

.PARAMETER CsvPath
    Caminho do arquivo CSV de saida.

.PARAMETER Aplicar
    Liga o Azure Hybrid Benefit nas VMs elegiveis. Sem este parametro o script so audita.

.PARAMETER TagNome
    Nome da TAG que marca a VM como coberta por licenca. Padrao: ahb-elegivel.

.PARAMETER TagValor
    Valor esperado da TAG. Padrao: sim.

.EXAMPLE
    ./Invoke-AhbAuditoria.ps1 -SubscriptionId '00000000-0000-0000-0000-000000000000'

.EXAMPLE
    ./Invoke-AhbAuditoria.ps1 -SubscriptionId '00000000-0000-0000-0000-000000000000' -Aplicar -WhatIf

.EXAMPLE
    ./Invoke-AhbAuditoria.ps1 -SubscriptionId '00000000-0000-0000-0000-000000000000' -Aplicar
#>

[CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
param(
    [string[]]$SubscriptionId,

    [string]$CsvPath = (Join-Path -Path (Get-Location) -ChildPath ("ahb-auditoria-{0}.csv" -f (Get-Date -Format 'yyyyMMdd-HHmm'))),

    [switch]$Aplicar,

    [ValidateNotNullOrEmpty()]
    [string]$TagNome = 'ahb-elegivel',

    [ValidateNotNullOrEmpty()]
    [string]$TagValor = 'sim'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-ValorDaTag {
    param($Tags, [string]$Nome)

    if ($null -eq $Tags) { return $null }

    # As TAGs chegam como dicionario (Get-AzVM) ou como objeto (Search-AzGraph). Trata os dois.
    if ($Tags -is [System.Collections.IDictionary]) {
        foreach ($chave in $Tags.Keys) {
            if ($chave -ieq $Nome) { return [string]$Tags[$chave] }
        }
        return $null
    }

    $propriedade = $Tags.PSObject.Properties | Where-Object { $_.Name -ieq $Nome } | Select-Object -First 1
    if ($null -eq $propriedade) { return $null }

    return [string]$propriedade.Value
}

# --- 1. Sessao -------------------------------------------------------------------------------
$contexto = Get-AzContext
if ($null -eq $contexto) {
    throw 'Nenhuma sessao do Azure encontrada. Execute Connect-AzAccount antes de rodar o script.'
}
Write-Host ("Conta: {0} | Tenant: {1}" -f $contexto.Account.Id, $contexto.Tenant.Id)

# --- 2. Consulta no Resource Graph, com paginacao ---------------------------------------------
$consulta = @"
resources
| where type =~ 'microsoft.compute/virtualmachines'
| where tostring(properties.storageProfile.osDisk.osType) =~ 'Windows'
| extend licenseType = tostring(properties.licenseType)
| extend publisher = tostring(properties.storageProfile.imageReference.publisher)
| project id, subscriptionId, resourceGroup, name, location,
    vmSize = tostring(properties.hardwareProfile.vmSize),
    publisher,
    offer = tostring(properties.storageProfile.imageReference.offer),
    sku = tostring(properties.storageProfile.imageReference.sku),
    licenseType,
    powerState = tostring(properties.extended.instanceView.powerState.code),
    tags
| order by id asc
"@

$linhas = [System.Collections.Generic.List[object]]::new()
$skipToken = $null

do {
    $parametros = @{
        Query = $consulta
        First = 1000
    }
    if ($SubscriptionId) { $parametros.Subscription = $SubscriptionId } else { $parametros.UseTenantScope = $true }
    if ($skipToken) { $parametros.SkipToken = $skipToken }

    try {
        $resposta = Search-AzGraph @parametros
    }
    catch {
        throw "Falha na consulta ao Resource Graph: $($_.Exception.Message)"
    }

    foreach ($item in $resposta.Data) { $linhas.Add($item) }
    $skipToken = $resposta.SkipToken
} while ($skipToken)

Write-Host ("VMs Windows encontradas: {0}" -f $linhas.Count)

if ($linhas.Count -eq 0) {
    Write-Warning 'Nenhuma VM Windows no escopo consultado. Nada a exportar.'
    return
}

# --- 3. vCPUs por tamanho de VM (uma chamada por regiao) --------------------------------------
$vcpusPorRegiao = @{}
foreach ($regiao in ($linhas | Select-Object -ExpandProperty location -Unique)) {
    $mapa = @{}
    try {
        Get-AzComputeResourceSku -Location $regiao |
            Where-Object { $_.ResourceType -eq 'virtualMachines' } |
            ForEach-Object {
                $capacidade = $_.Capabilities | Where-Object { $_.Name -eq 'vCPUs' } | Select-Object -First 1
                if ($null -ne $capacidade) { $mapa[$_.Name] = [int]$capacidade.Value }
            }
    }
    catch {
        Write-Warning ("Nao foi possivel ler os tamanhos de VM da regiao {0}: {1}" -f $regiao, $_.Exception.Message)
    }
    $vcpusPorRegiao[$regiao] = $mapa
}

# --- 4. Relatorio -----------------------------------------------------------------------------
$relatorio = foreach ($vm in $linhas) {
    # Forca string: licenseType ausente pode chegar como $null, e o switch nao casaria com o padrao vazio.
    $licenca = [string]$vm.licenseType

    $situacao = switch -Regex ($licenca) {
        '^Windows_Server$' { 'AHB ligado'; break }
        '^Windows_Client$' { 'Windows client'; break }
        '^(None)?$'        { 'AHB desligado'; break }
        default            { "Outro valor: $licenca" }
    }

    $vcpus = $null
    if ($vcpusPorRegiao.ContainsKey($vm.location) -and $vcpusPorRegiao[$vm.location].ContainsKey($vm.vmSize)) {
        $vcpus = $vcpusPorRegiao[$vm.location][$vm.vmSize]
    }

    $nucleosEstimados = $null
    if ($null -ne $vcpus) { $nucleosEstimados = [math]::Max(8, $vcpus) }

    $valorTag = Get-ValorDaTag -Tags $vm.tags -Nome $TagNome

    [pscustomobject]@{
        SubscriptionId   = $vm.subscriptionId
        ResourceGroup    = $vm.resourceGroup
        Nome             = $vm.name
        Regiao           = $vm.location
        Tamanho          = $vm.vmSize
        vCPUs            = $vcpus
        NucleosEstimados = $nucleosEstimados
        Publisher        = $vm.publisher
        Offer            = $vm.offer
        Sku              = $vm.sku
        ImagemCliente    = ($vm.publisher -ieq 'MicrosoftWindowsDesktop')
        LicenseType      = $licenca
        Situacao         = $situacao
        PowerState       = $vm.powerState
        TagElegibilidade = $valorTag
        Id               = $vm.id
    }
}

try {
    # -WhatIf:$false para o CSV ser gravado tambem quando o script roda com -Aplicar -WhatIf.
    $relatorio | Sort-Object Situacao, Nome | Export-Csv -Path $CsvPath -NoTypeInformation -Encoding utf8 -WhatIf:$false
    Write-Host ("CSV gravado em: {0}" -f $CsvPath)
}
catch {
    throw "Falha ao gravar o CSV em '$CsvPath': $($_.Exception.Message)"
}

$relatorio | Group-Object Situacao | Sort-Object Name | ForEach-Object {
    $nucleos = 0
    foreach ($linha in $_.Group) {
        if ($null -ne $linha.NucleosEstimados) { $nucleos += $linha.NucleosEstimados }
    }
    Write-Host ("{0,-16} VMs: {1,4} | nucleos estimados: {2}" -f $_.Name, $_.Count, $nucleos)
}

# --- 5. Aplicacao (opcional) ------------------------------------------------------------------
if (-not $Aplicar) {
    Write-Host 'Modo auditoria. Nenhuma VM foi alterada. Use -Aplicar para ligar o beneficio nas VMs marcadas com a TAG.'
    return
}

$candidatas = @($relatorio | Where-Object {
        $_.Situacao -eq 'AHB desligado' -and
        -not $_.ImagemCliente -and
        $_.TagElegibilidade -ieq $TagValor
    })

Write-Host ("VMs com AHB desligado e TAG {0}={1}: {2}" -f $TagNome, $TagValor, $candidatas.Count)

$alteradas = 0
$falhas = 0
$assinaturaAtual = (Get-AzContext).Subscription.Id

foreach ($candidata in $candidatas) {
    $alvo = "{0}/{1}" -f $candidata.ResourceGroup, $candidata.Nome

    if (-not $PSCmdlet.ShouldProcess($alvo, 'Definir licenseType = Windows_Server (Azure Hybrid Benefit)')) {
        continue
    }

    try {
        if ($assinaturaAtual -ne $candidata.SubscriptionId) {
            Set-AzContext -SubscriptionId $candidata.SubscriptionId | Out-Null
            $assinaturaAtual = $candidata.SubscriptionId
        }

        $objetoVm = Get-AzVM -ResourceGroupName $candidata.ResourceGroup -Name $candidata.Nome

        # O Resource Graph pode estar atrasado. A TAG e o licenseType sao conferidos de novo na propria VM.
        if ((Get-ValorDaTag -Tags $objetoVm.Tags -Nome $TagNome) -ine $TagValor) {
            Write-Warning ("PULADA {0}: a TAG {1}={2} nao esta mais na VM." -f $alvo, $TagNome, $TagValor)
            continue
        }
        if ($objetoVm.LicenseType -ieq 'Windows_Server') {
            Write-Host ("JA OK  {0}" -f $alvo)
            continue
        }

        $objetoVm.LicenseType = 'Windows_Server'
        Update-AzVM -ResourceGroupName $candidata.ResourceGroup -VM $objetoVm | Out-Null

        $alteradas++
        Write-Host ("OK     {0}" -f $alvo)
    }
    catch {
        $falhas++
        Write-Warning ("FALHA  {0}: {1}" -f $alvo, $_.Exception.Message)
    }
}

Write-Host ("Concluido. Alteradas: {0} | Falhas: {1} | Candidatas: {2}" -f $alteradas, $falhas, $candidatas.Count)

if ($falhas -gt 0) { exit 1 }
