param(
    [int]$Top = 90,
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'output')
)

. (Join-Path $PSScriptRoot '..\_Common\GraphHelpers.ps1')
Connect-GraphForScopes -Scopes @('SecurityEvents.Read.All')

$scores = Invoke-GraphPagedRequest -Uri "https://graph.microsoft.com/v1.0/security/secureScores?`$top=$Top"
$ordered = @($scores | Sort-Object createdDateTime)

$rows = for ($index = 0; $index -lt $ordered.Count; $index++) {
    $score = $ordered[$index]
    $previous = if ($index -gt 0) { $ordered[$index - 1] } else { $null }
    $current = [double]$score.currentScore
    $max = [double]$score.maxScore
    $percentage = if ($max -gt 0) { [math]::Round(($current / $max) * 100, 2) } else { $null }
    $variation = if ($previous) { [math]::Round($current - [double]$previous.currentScore, 2) } else { $null }

    [pscustomobject]@{
        DataScoreUTC = $score.createdDateTime
        CurrentScore = $current
        MaxScore = $max
        Percentual = $percentage
        VariacaoPontos = $variation
        UsuariosAtivos = $score.activeUserCount
        UsuariosLicenciados = $score.licensedUserCount
        ServicosHabilitados = ($score.enabledServices -join '; ')
        ComparacaoMedia = ConvertTo-CompactJson $score.averageComparativeScores
        PontuacaoPorCategoria = ConvertTo-CompactJson $score.controlScores
        Recomendacao = if ($percentage -lt 50) { 'Priorizar controles com maior quantidade de pontos disponíveis.' } elseif ($percentage -lt 80) { 'Executar plano contínuo de melhoria por categoria.' } else { 'Manter evolução e revisar controles pendentes.' }
        Causa = 'A pontuação reflete os controles implementados e os serviços habilitados na data da avaliação.'
        Solucao = 'Correlacionar o histórico com os perfis de controle e priorizar ações de maior impacto e menor custo operacional.'
        Documentacao = 'https://learn.microsoft.com/graph/api/security-list-securescores'
    }
}

Export-GraphCsv -Data @($rows) -Path (Join-Path $OutputDirectory 'microsoft-secure-score-historico.csv')
