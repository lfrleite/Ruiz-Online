# Arquivo: 012-Export-ArgQuery.ps1
<#
.SYNOPSIS
    Executa uma consulta do Azure Resource Graph a partir de um arquivo .kql,
    pagina o resultado com skip token e exporta tudo para CSV.

.DESCRIPTION
    Usa a sessão já autenticada do Azure PowerShell (Connect-AzAccount).
    Nenhuma credencial é lida ou gravada pelo script.
    A consulta precisa projetar a coluna id e não pode usar limit, take ou sample,
    senão o Resource Graph não devolve o skip token e o resultado para na primeira página.

.EXAMPLE
    ./012-Export-ArgQuery.ps1 -QueryFile ./012-01-inventario-vms.kql -OutputCsv ./inventario-vms.csv -UseTenantScope

.EXAMPLE
    ./012-Export-ArgQuery.ps1 -QueryFile ./012-06-discos-sku.kql -OutputCsv ./discos.csv -ManagementGroup 'mg-landingzones'
#>
[CmdletBinding(DefaultParameterSetName = 'Contexto')]
param(
    [Parameter(Mandatory)]
    [string]$QueryFile,

    [Parameter(Mandatory)]
    [string]$OutputCsv,

    [Parameter(ParameterSetName = 'Assinatura', Mandatory)]
    [string[]]$Subscription,

    [Parameter(ParameterSetName = 'ManagementGroup', Mandatory)]
    [string[]]$ManagementGroup,

    [Parameter(ParameterSetName = 'Tenant', Mandatory)]
    [switch]$UseTenantScope,

    [ValidateRange(1, 1000)]
    [int]$PageSize = 1000
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command -Name Search-AzGraph -ErrorAction SilentlyContinue)) {
    throw "Cmdlet Search-AzGraph não encontrado. Instale o módulo: Install-Module -Name Az.ResourceGraph -Repository PSGallery -Scope CurrentUser"
}

if (-not (Get-AzContext)) {
    throw "Nenhuma sessão ativa no Azure PowerShell. Rode Connect-AzAccount antes."
}

if (-not (Test-Path -Path $QueryFile -PathType Leaf)) {
    throw "Arquivo de consulta não encontrado: $QueryFile"
}

$query = Get-Content -Path $QueryFile -Raw
if ([string]::IsNullOrWhiteSpace($query)) {
    throw "O arquivo $QueryFile está vazio."
}

$parametros = @{
    Query = $query
    First = $PageSize
}
switch ($PSCmdlet.ParameterSetName) {
    'Assinatura'      { $parametros.Subscription = $Subscription }
    'ManagementGroup' { $parametros.ManagementGroup = $ManagementGroup }
    'Tenant'          { $parametros.UseTenantScope = $true }
}

$registros = [System.Collections.Generic.List[object]]::new()
$pagina = 0

try {
    do {
        $pagina++
        $resposta = Search-AzGraph @parametros

        foreach ($item in $resposta.Data) {
            $registros.Add($item)
        }
        Write-Host ("Página {0}: {1} registros (acumulado: {2})" -f $pagina, @($resposta.Data).Count, $registros.Count)

        $parametros.SkipToken = $resposta.SkipToken

        # Pausa curta para não esbarrar no limite de consultas por usuário.
        if ($resposta.SkipToken) { Start-Sleep -Milliseconds 400 }
    } while ($resposta.SkipToken)
}
catch {
    throw "Falha ao consultar o Resource Graph na página $pagina. Detalhe: $($_.Exception.Message)"
}

if ($registros.Count -eq 0) {
    Write-Warning "A consulta não retornou registros. Confira o escopo e as permissões de leitura."
    return
}

if ($pagina -eq 1 -and $registros.Count -eq $PageSize) {
    Write-Warning "Vieram exatamente $PageSize registros e nenhum skip token. O resultado pode estar truncado: confira se a consulta projeta a coluna id e não usa limit, take ou sample."
}

# Colunas dinâmicas (tags, por exemplo) viram JSON em texto para caber em uma célula do CSV.
$linhas = foreach ($item in $registros) {
    $linha = [ordered]@{}
    foreach ($prop in $item.PSObject.Properties) {
        if ($null -eq $prop.Value -or $prop.Value -is [string] -or $prop.Value -is [ValueType]) {
            $linha[$prop.Name] = $prop.Value
        }
        else {
            $linha[$prop.Name] = ($prop.Value | ConvertTo-Json -Compress -Depth 10)
        }
    }
    [pscustomobject]$linha
}

try {
    $linhas | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding utf8
}
catch {
    throw "Falha ao gravar o CSV em $OutputCsv. Detalhe: $($_.Exception.Message)"
}

Write-Host ("Exportados {0} registros para {1}" -f $registros.Count, $OutputCsv)
