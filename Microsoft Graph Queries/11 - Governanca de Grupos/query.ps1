param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'output')
)

. (Join-Path $PSScriptRoot '..\_Common\GraphHelpers.ps1')
Connect-GraphForScopes -Scopes @('Group.Read.All','GroupMember.Read.All','GroupSettings.Read.All','Policy.Read.All')

$groups = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/groups?$select=id,displayName,description,groupTypes,securityEnabled,mailEnabled,membershipRule,membershipRuleProcessingState,onPremisesSyncEnabled,isAssignableToRole,createdDateTime,renewedDateTime,expirationDateTime&$top=999'
$rows = [System.Collections.Generic.List[object]]::new()

foreach ($group in $groups) {
    $owners = Invoke-GraphPagedRequest -Uri "https://graph.microsoft.com/v1.0/groups/$($group.id)/owners?`$select=id,displayName,userPrincipalName,userType"
    $members = Invoke-GraphPagedRequest -Uri "https://graph.microsoft.com/v1.0/groups/$($group.id)/members?`$select=id&`$top=999"
    $ownerCount = $owners.Count

    $rows.Add([pscustomobject]@{
        GroupId = $group.id
        NomeGrupo = $group.displayName
        Descricao = $group.description
        Tipos = ($group.groupTypes -join '; ')
        SecurityEnabled = $group.securityEnabled
        MailEnabled = $group.mailEnabled
        Dinamico = $group.groupTypes -contains 'DynamicMembership'
        MembershipRule = $group.membershipRule
        MembershipRuleProcessingState = $group.membershipRuleProcessingState
        SincronizadoOnPremises = $group.onPremisesSyncEnabled
        RoleAssignable = $group.isAssignableToRole
        DataCriacaoUTC = $group.createdDateTime
        DataRenovacaoUTC = $group.renewedDateTime
        DataExpiracaoUTC = $group.expirationDateTime
        QuantidadeProprietarios = $ownerCount
        Proprietarios = ($owners | ForEach-Object { $_.displayName }) -join '; '
        ConvidadoComoProprietario = @($owners | Where-Object userType -eq 'Guest').Count -gt 0
        QuantidadeMembros = $members.Count
        Recomendacao = if ($ownerCount -eq 0) { 'Prioridade: atribuir proprietário responsável.' } elseif ($ownerCount -eq 1) { 'Adicionar proprietário de contingência.' } elseif (@($owners | Where-Object userType -eq 'Guest').Count -gt 0) { 'Revisar convidado como proprietário.' } elseif ($members.Count -eq 0) { 'Revisar grupo vazio.' } else { 'Manter revisão periódica.' }
        Causa = if ($ownerCount -eq 0) { 'Grupo sem proprietário identificado.' } elseif ($members.Count -eq 0) { 'Grupo sem membros identificado.' } else { 'Governança calculada pelos proprietários e membros retornados.' }
        Solucao = 'Definir responsáveis, convenção de nomenclatura, expiração, revisão de acesso e restrição de criação conforme política.'
        Documentacao = 'https://learn.microsoft.com/graph/api/group-list-owners'
    })
}

$settings = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/groupSettings'
$authorization = (Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/policies/authorizationPolicy')[0]

Export-GraphCsv -Data $rows.ToArray() -Path (Join-Path $OutputDirectory 'governanca-grupos.csv')
Export-GraphCsv -Data @([pscustomobject]@{
    GroupSettings = ConvertTo-CompactJson $settings
    AuthorizationPolicy = ConvertTo-CompactJson $authorization
    Documentacao = 'https://learn.microsoft.com/graph/api/group-list-settings'
}) -Path (Join-Path $OutputDirectory 'configuracoes-governanca-grupos.csv')
