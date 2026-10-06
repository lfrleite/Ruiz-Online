#Requires -Version 7.0
#Requires -Modules Az.Accounts, Az.ResourceGraph, Az.Resources

<#
.SYNOPSIS
    Lista candidatos a recurso orfao com Azure Resource Graph, gera CSV e, se pedido, marca com TAG.

.DESCRIPTION
    Executa cada arquivo .kql da pasta de consultas, pagina o resultado, grava tudo em um CSV
    e mostra um resumo por categoria. Com -MarcarComTag, aplica as TAGs orfao-candidato,
    orfao-detectado-em e orfao-categoria nos recursos encontrados. O script nao apaga nada.

    Cada consulta precisa devolver as colunas:
    id, name, resourceGroup, subscriptionId, location, detalhe, detectadoEm

.PARAMETER PastaConsultas
    Pasta com os arquivos .kql. Padrao: subpasta "consultas" ao lado do script.

.PARAMETER SubscriptionId
    Uma ou mais assinaturas. Sem este parametro e sem -ManagementGroup, a consulta roda no tenant inteiro.

.PARAMETER ManagementGroup
    ID do management group usado como escopo.

.PARAMETER CaminhoCsv
    Caminho do CSV de saida. Padrao: recursos-orfaos-<data>.csv na pasta atual.

.PARAMETER MarcarComTag
    Aplica as TAGs nos candidatos. Aceita -WhatIf e -Confirm.

.EXAMPLE
    ./Find-RecursosOrfaos.ps1 -SubscriptionId '00000000-0000-0000-0000-000000000000'

.EXAMPLE
    ./Find-RecursosOrfaos.ps1 -ManagementGroup 'mg-lab' -MarcarComTag -WhatIf
#>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
param(
    [string]$PastaConsultas = (Join-Path -Path $PSScriptRoot -ChildPath 'consultas'),

    [string[]]$SubscriptionId,

    [string]$ManagementGroup,

    [string]$CaminhoCsv = (Join-Path -Path (Get-Location) -ChildPath ('recursos-orfaos-{0:yyyyMMdd-HHmm}.csv' -f (Get-Date))),

    [switch]$MarcarComTag
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$colunasObrigatorias = @('id', 'name', 'resourceGroup', 'subscriptionId', 'location', 'detalhe', 'detectadoEm')
$tamanhoPagina = 1000

if ($SubscriptionId -and $ManagementGroup) {
    throw 'Informe -SubscriptionId ou -ManagementGroup, nao os dois.'
}

if (-not (Get-AzContext)) {
    throw 'Nenhuma sessao do Azure encontrada. Rode Connect-AzAccount e execute o script de novo.'
}

if (-not (Test-Path -Path $PastaConsultas -PathType Container)) {
    throw "Pasta de consultas nao encontrada: $PastaConsultas"
}

$arquivos = @(Get-ChildItem -Path $PastaConsultas -Filter '*.kql' -File | Sort-Object -Property Name)
if ($arquivos.Count -eq 0) {
    throw "Nenhum arquivo .kql em $PastaConsultas"
}

function Invoke-ConsultaPaginada {
    param(
        [Parameter(Mandatory)][string]$Consulta
    )

    $parametros = @{
        Query = $Consulta
        First = $tamanhoPagina
    }

    if ($ManagementGroup) {
        $parametros.ManagementGroup = $ManagementGroup
    }
    elseif ($SubscriptionId) {
        $parametros.Subscription = $SubscriptionId
    }
    else {
        $parametros.UseTenantScope = $true
    }

    $linhas = [System.Collections.Generic.List[object]]::new()

    do {
        $resposta = Search-AzGraph @parametros
        foreach ($linha in $resposta.Data) {
            $linhas.Add($linha)
        }
        $parametros.SkipToken = $resposta.SkipToken
    } while ($resposta.SkipToken)

    return $linhas
}

$achados = [System.Collections.Generic.List[object]]::new()
$falhas = 0

foreach ($arquivo in $arquivos) {
    $categoria = $arquivo.BaseName

    # Remove as linhas de comentario antes de enviar a consulta
    $consulta = (Get-Content -Path $arquivo.FullName |
        Where-Object { $_ -notmatch '^\s*//' }) -join "`n"

    try {
        $linhas = @(Invoke-ConsultaPaginada -Consulta $consulta)

        foreach ($linha in $linhas) {
            $faltando = @($colunasObrigatorias | Where-Object { $_ -notin $linha.PSObject.Properties.Name })
            if ($faltando.Count -gt 0) {
                throw "A consulta nao devolveu a(s) coluna(s): $($faltando -join ', ')"
            }

            $achados.Add([pscustomobject]@{
                    Categoria      = $categoria
                    Nome           = $linha.name
                    ResourceGroup  = $linha.resourceGroup
                    SubscriptionId = $linha.subscriptionId
                    Regiao         = $linha.location
                    Detalhe        = $linha.detalhe
                    DetectadoEm    = $linha.detectadoEm
                    Id             = $linha.id
                })
        }

        Write-Host ('{0,-45} {1,5} candidato(s)' -f $categoria, $linhas.Count)
    }
    catch {
        $falhas++
        Write-Warning "Falha na consulta '$categoria': $($_.Exception.Message)"
    }
}

if ($achados.Count -eq 0) {
    Write-Host 'Nenhum candidato encontrado no escopo consultado.'
}
else {
    # -WhatIf:$false: o relatorio e gravado mesmo no ensaio. O -WhatIf vale so para as TAGs.
    $achados | Export-Csv -Path $CaminhoCsv -NoTypeInformation -Encoding utf8BOM -WhatIf:$false
    Write-Host "CSV gravado em: $CaminhoCsv"
}

if ($MarcarComTag -and $achados.Count -gt 0) {
    $hoje = (Get-Date).ToString('yyyy-MM-dd')
    $marcados = 0
    $jaMarcados = 0
    $falhasDeTag = 0

    foreach ($grupo in ($achados | Group-Object -Property Id)) {
        $recursoId = $grupo.Name

        # Quem ja tem data de deteccao mantem a data original
        if ($grupo.Group[0].DetectadoEm) {
            $jaMarcados++
            continue
        }

        $tags = @{
            'orfao-candidato'    = 'true'
            'orfao-detectado-em' = $hoje
            'orfao-categoria'    = (($grupo.Group.Categoria | Sort-Object -Unique) -join '+')
        }

        if ($PSCmdlet.ShouldProcess($recursoId, 'Aplicar TAGs de candidato a orfao')) {
            try {
                Update-AzTag -ResourceId $recursoId -Tag $tags -Operation Merge | Out-Null
                $marcados++
            }
            catch {
                $falhasDeTag++
                Write-Warning "Nao foi possivel marcar $recursoId : $($_.Exception.Message)"
            }
        }
    }

    Write-Host "TAGs aplicadas: $marcados | ja marcados antes: $jaMarcados | falhas: $falhasDeTag"

    $falhas += $falhasDeTag
}

if ($falhas -gt 0) {
    Write-Warning "Execucao terminou com $falhas falha(s). Revise os avisos acima."
    exit 1
}
