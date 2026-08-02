Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Connect-GraphForScopes {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$Scopes
    )

    if (-not (Get-Module -ListAvailable -Name Microsoft.Graph.Authentication)) {
        throw 'Instale o módulo Microsoft.Graph.Authentication antes da execução: Install-Module Microsoft.Graph.Authentication -Scope CurrentUser'
    }

    Import-Module Microsoft.Graph.Authentication
    Connect-MgGraph -Scopes $Scopes -NoWelcome
}

function Invoke-GraphPagedRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Uri,

        [hashtable]$Headers = @{}
    )

    $items = [System.Collections.Generic.List[object]]::new()
    $nextLink = $Uri

    while ($nextLink) {
        $response = Invoke-MgGraphRequest -Method GET -Uri $nextLink -Headers $Headers

        if ($response -is [System.Collections.IDictionary] -and $response.ContainsKey('value')) {
            foreach ($item in $response.value) {
                $items.Add([pscustomobject]$item)
            }
            $nextLink = $response.'@odata.nextLink'
        }
        elseif ($response.PSObject.Properties.Name -contains 'value') {
            foreach ($item in $response.value) {
                $items.Add($item)
            }
            $nextLink = $response.'@odata.nextLink'
        }
        else {
            $items.Add([pscustomobject]$response)
            $nextLink = $null
        }
    }

    return $items
}

function ConvertTo-CompactJson {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    process {
        if ($null -eq $InputObject) {
            return ''
        }

        return ($InputObject | ConvertTo-Json -Depth 20 -Compress)
    }
}

function Export-GraphCsv {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object[]]$Data,

        [Parameter(Mandatory)]
        [string]$Path
    )

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $Data | Export-Csv -Path $Path -NoTypeInformation -Encoding utf8BOM
    Write-Host "Arquivo criado: $Path"
}

function Export-GraphCsvReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Uri,

        [Parameter(Mandatory)]
        [string]$Path
    )

    $directory = Split-Path -Parent $Path
    if ($directory -and -not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    $response = Invoke-MgGraphRequest -Method GET -Uri $Uri -OutputType HttpResponseMessage
    $content = $response.Content.ReadAsStringAsync().GetAwaiter().GetResult()
    Set-Content -Path $Path -Value $content -Encoding utf8BOM
    Write-Host "Arquivo criado: $Path"
}
