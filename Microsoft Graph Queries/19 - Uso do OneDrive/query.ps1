param(
    [ValidateSet('D7','D30','D90','D180')]
    [string]$Period = 'D30',
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'output')
)

. (Join-Path $PSScriptRoot '..\_Common\GraphHelpers.ps1')
Connect-GraphForScopes -Scopes @('Reports.Read.All')

$uri = "https://graph.microsoft.com/v1.0/reports/getOneDriveUsageAccountDetail(period='$Period')"
Export-GraphCsvReport -Uri $uri -Path (Join-Path $OutputDirectory "onedrive-usage-$Period.csv")

Write-Host 'O relatório CSV contém atividade, arquivos e armazenamento por conta. Aplique as recomendações descritas no README durante a análise.'
