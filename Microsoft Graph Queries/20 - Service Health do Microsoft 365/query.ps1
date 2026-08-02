param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'output')
)

. (Join-Path $PSScriptRoot '..\_Common\GraphHelpers.ps1')
Connect-GraphForScopes -Scopes @('ServiceHealth.Read.All','ServiceMessage.Read.All')

$health = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/admin/serviceAnnouncement/healthOverviews'
$issues = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/admin/serviceAnnouncement/issues?$top=999'
$messages = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/admin/serviceAnnouncement/messages?$top=999'

$healthRows = foreach ($item in $health) {
    [pscustomobject]@{
        Service = $item.service
        Status = $item.status
        Recomendacao = if ($item.status -ne 'serviceOperational') { 'Acompanhar incidentes e advisories relacionados.' } else { 'Serviço operacional.' }
        Causa = "Status atual: $($item.status)"
        Solucao = 'Consultar issues ativas, impacto ao usuário e atualizações da Microsoft.'
        Documentacao = 'https://learn.microsoft.com/graph/api/serviceannouncement-list-healthoverviews'
    }
}

$issueRows = foreach ($item in $issues) {
    [pscustomobject]@{
        IssueId = $item.id
        Service = $item.service
        Feature = $item.feature
        Classification = $item.classification
        Origin = $item.origin
        Status = $item.status
        StartDateTimeUTC = $item.startDateTime
        EndDateTimeUTC = $item.endDateTime
        LastModifiedDateTimeUTC = $item.lastModifiedDateTime
        Title = $item.title
        ImpactDescription = $item.impactDescription
        Posts = ConvertTo-CompactJson $item.posts
        Recomendacao = if ($item.status -notin @('serviceRestored','resolved')) { 'Acompanhar até a resolução e avaliar impacto interno.' } else { 'Registrar resolução e lições aprendidas quando aplicável.' }
        Causa = $item.impactDescription
        Solucao = 'Seguir orientações publicadas nos posts do incidente e manter comunicação aos usuários afetados.'
        Documentacao = 'https://learn.microsoft.com/graph/api/serviceannouncement-list-issues'
    }
}

Export-GraphCsv -Data @($healthRows) -Path (Join-Path $OutputDirectory 'm365-health-overview.csv')
Export-GraphCsv -Data @($issueRows) -Path (Join-Path $OutputDirectory 'm365-service-issues.csv')
Export-GraphCsv -Data @($messages) -Path (Join-Path $OutputDirectory 'm365-message-center.csv')
