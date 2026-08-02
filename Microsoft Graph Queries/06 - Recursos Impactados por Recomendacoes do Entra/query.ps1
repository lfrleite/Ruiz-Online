param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'output')
)

. (Join-Path $PSScriptRoot '..\_Common\GraphHelpers.ps1')
Connect-GraphForScopes -Scopes @('DirectoryRecommendations.Read.All')

$recommendations = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/beta/directory/recommendations'
$rows = [System.Collections.Generic.List[object]]::new()

foreach ($recommendation in $recommendations) {
    $resources = Invoke-GraphPagedRequest -Uri "https://graph.microsoft.com/beta/directory/recommendations/$($recommendation.id)/impactedResources"
    foreach ($resource in $resources) {
        $rows.Add([pscustomobject]@{
            RecommendationId = $recommendation.id
            Recomendacao = $recommendation.displayName
            Prioridade = $recommendation.priority
            StatusRecomendacao = $recommendation.status
            ImpactedResourceId = $resource.id
            ResourceType = $resource.resourceType
            SubjectId = $resource.subjectId
            NomeRecurso = $resource.displayName
            Rank = $resource.rank
            StatusRecurso = $resource.status
            DataIdentificacaoUTC = $resource.addedDateTime
            UltimaAlteracaoUTC = $resource.lastModifiedDateTime
            AlteradoPor = $resource.lastModifiedBy
            PortalUrl = $resource.portalUrl
            ApiUrl = $resource.apiUrl
            DetalhesAdicionais = ConvertTo-CompactJson $resource.additionalDetails
            Causa = 'O recurso foi identificado pelo serviço como impactado pela recomendação.'
            Solucao = ConvertTo-CompactJson $recommendation.actionSteps
            Documentacao = $recommendation.actionUrl
        })
    }
}

Export-GraphCsv -Data $rows.ToArray() -Path (Join-Path $OutputDirectory 'entra-recursos-impactados.csv')
