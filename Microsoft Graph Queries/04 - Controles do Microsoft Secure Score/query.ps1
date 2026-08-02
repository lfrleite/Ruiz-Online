param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'output')
)

. (Join-Path $PSScriptRoot '..\_Common\GraphHelpers.ps1')
Connect-GraphForScopes -Scopes @('SecurityEvents.Read.All')

$latestScore = (Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/security/secureScores?$top=1')[0]
$profiles = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/security/secureScoreControlProfiles'
$profileIndex = @{}
foreach ($profile in $profiles) {
    $profileIndex[[string]$profile.id] = $profile
}

$rows = foreach ($control in $latestScore.controlScores) {
    $profile = $profileIndex[[string]$control.controlName]
    $score = [double]$control.score
    $max = if ($profile.maxScore) { [double]$profile.maxScore } else { [double]$control.score }
    $available = [math]::Max(0, $max - $score)

    [pscustomobject]@{
        DataScoreUTC = $latestScore.createdDateTime
        ControlId = $control.controlName
        Titulo = $profile.title
        Categoria = $profile.controlCategory
        Produto = $profile.service
        ScoreAtual = $score
        ScoreMaximo = $max
        PontosDisponiveis = $available
        StatusImplementacao = $control.description
        TipoAcao = $profile.actionType
        CustoImplementacao = $profile.implementationCost
        ImpactoUsuario = $profile.userImpact
        Rank = $profile.rank
        Tier = $profile.tier
        Ameacas = ($profile.threats -join '; ')
        Recomendacao = $profile.title
        Causa = $profile.actionPlanTitle
        Descricao = $profile.description
        Solucao = $profile.remediation
        ImpactoRemediacao = $profile.remediationImpact
        Documentacao = $profile.actionUrl
        Depreciado = $profile.deprecated
    }
}

Export-GraphCsv -Data @($rows | Sort-Object PontosDisponiveis -Descending) -Path (Join-Path $OutputDirectory 'microsoft-secure-score-controles.csv')
