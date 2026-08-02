param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'output')
)

. (Join-Path $PSScriptRoot '..\_Common\GraphHelpers.ps1')
Connect-GraphForScopes -Scopes @('DirectoryRecommendations.Read.All')

$uri = "https://graph.microsoft.com/beta/directory/recommendations?`$filter=category eq 'identitySecureScore'"
$recommendations = Invoke-GraphPagedRequest -Uri $uri

$rows = foreach ($item in $recommendations) {
    $current = if ($null -ne $item.currentScore) { [double]$item.currentScore } else { 0 }
    $max = if ($null -ne $item.maxScore) { [double]$item.maxScore } else { 0 }
    [pscustomobject]@{
        RecommendationId = $item.id
        Nome = $item.displayName
        Categoria = $item.category
        Prioridade = $item.priority
        Status = $item.status
        ScoreAtual = $current
        ScoreMaximo = $max
        PontosDisponiveis = [math]::Max(0, $max - $current)
        FeatureAreas = ($item.featureAreas -join '; ')
        RequiredLicenses = ConvertTo-CompactJson $item.requiredLicenses
        ReleaseType = $item.releaseType
        DataCriacaoUTC = $item.createdDateTime
        UltimaAvaliacaoUTC = $item.lastCheckedDateTime
        DataImpactoUTC = $item.impactStartDateTime
        Recomendacao = $item.displayName
        Causa = ConvertTo-CompactJson $item.insights
        Beneficios = ConvertTo-CompactJson $item.benefits
        Solucao = ConvertTo-CompactJson $item.actionSteps
        ImpactoRemediacao = ConvertTo-CompactJson $item.remediationImpact
        Documentacao = $item.actionUrl
    }
}

Export-GraphCsv -Data @($rows | Sort-Object PontosDisponiveis -Descending) -Path (Join-Path $OutputDirectory 'identity-secure-score-recomendacoes.csv')
