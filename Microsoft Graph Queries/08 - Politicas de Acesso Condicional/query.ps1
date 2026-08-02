param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'output')
)

. (Join-Path $PSScriptRoot '..\_Common\GraphHelpers.ps1')
Connect-GraphForScopes -Scopes @('Policy.Read.All')

$policies = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/identity/conditionalAccess/policies'

$rows = foreach ($policy in $policies) {
    $state = [string]$policy.state
    $grantControls = @($policy.grantControls.builtInControls)
    [pscustomobject]@{
        PolicyId = $policy.id
        NomePolitica = $policy.displayName
        Estado = $state
        DataCriacaoUTC = $policy.createdDateTime
        UltimaModificacaoUTC = $policy.modifiedDateTime
        UsuariosIncluidos = ConvertTo-CompactJson $policy.conditions.users.includeUsers
        UsuariosExcluidos = ConvertTo-CompactJson $policy.conditions.users.excludeUsers
        GruposIncluidos = ConvertTo-CompactJson $policy.conditions.users.includeGroups
        GruposExcluidos = ConvertTo-CompactJson $policy.conditions.users.excludeGroups
        RolesIncluidas = ConvertTo-CompactJson $policy.conditions.users.includeRoles
        Aplicacoes = ConvertTo-CompactJson $policy.conditions.applications
        UserRiskLevels = ConvertTo-CompactJson $policy.conditions.userRiskLevels
        SignInRiskLevels = ConvertTo-CompactJson $policy.conditions.signInRiskLevels
        Plataformas = ConvertTo-CompactJson $policy.conditions.platforms
        Localizacoes = ConvertTo-CompactJson $policy.conditions.locations
        ClientAppTypes = ConvertTo-CompactJson $policy.conditions.clientAppTypes
        DeviceFilter = ConvertTo-CompactJson $policy.conditions.devices
        GrantControls = ConvertTo-CompactJson $policy.grantControls
        SessionControls = ConvertTo-CompactJson $policy.sessionControls
        Recomendacao = if ($state -eq 'enabledForReportingButNotEnforced') { 'Homologar resultados e decidir promoção controlada para enabled.' } elseif ($state -eq 'disabled') { 'Revisar necessidade da política desabilitada.' } elseif ($grantControls.Count -eq 0) { 'Revisar política sem controle de concessão identificado.' } else { 'Manter revisão recorrente de cobertura e exclusões.' }
        Causa = "Estado atual: $state"
        Solucao = 'Validar impacto em report-only, contas de emergência, administradores, autenticação legada, risco e exclusões antes de habilitar.'
        Documentacao = 'https://learn.microsoft.com/graph/api/conditionalaccessroot-list-policies'
    }
}

Export-GraphCsv -Data @($rows) -Path (Join-Path $OutputDirectory 'conditional-access-policies.csv')
