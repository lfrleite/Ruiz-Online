param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'output')
)

. (Join-Path $PSScriptRoot '..\_Common\GraphHelpers.ps1')
Connect-GraphForScopes -Scopes @(
    'RoleManagement.Read.Directory',
    'RoleAssignmentSchedule.Read.Directory',
    'RoleEligibilitySchedule.Read.Directory'
)

$active = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignmentScheduleInstances?$expand=principal,roleDefinition&$top=999'
$eligible = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/roleManagement/directory/roleEligibilityScheduleInstances?$expand=principal,roleDefinition&$top=999'

function Convert-RoleRow {
    param($Item, [string]$AssignmentMode)

    $permanent = $null -eq $Item.endDateTime
    $privileged = if ($null -ne $Item.roleDefinition.isPrivileged) { [bool]$Item.roleDefinition.isPrivileged } else { $true }

    [pscustomobject]@{
        AssignmentMode = $AssignmentMode
        PrincipalId = $Item.principalId
        PrincipalName = $Item.principal.displayName
        PrincipalType = $Item.principal.'@odata.type'
        PrincipalUPN = $Item.principal.userPrincipalName
        UserType = $Item.principal.userType
        RoleDefinitionId = $Item.roleDefinitionId
        RoleName = $Item.roleDefinition.displayName
        RolePrivilegiada = $privileged
        DirectoryScopeId = $Item.directoryScopeId
        AppScopeId = $Item.appScopeId
        InicioUTC = $Item.startDateTime
        TerminoUTC = $Item.endDateTime
        Permanente = $permanent
        MemberType = $Item.memberType
        AssignmentType = $Item.assignmentType
        Recomendacao = if ($AssignmentMode -eq 'Ativa' -and $permanent -and $privileged) { 'Revisar atribuição privilegiada ativa e permanente.' } elseif ($Item.principal.userType -eq 'Guest') { 'Revisar atribuição administrativa para convidado.' } else { 'Manter revisão periódica e princípio de menor privilégio.' }
        Causa = if ($permanent) { 'A atribuição não possui data de término.' } else { 'Atribuição com janela temporal identificada.' }
        Solucao = 'Avaliar elegibilidade via PIM, expiração, aprovação, MFA para ativação e atribuição por grupo quando aplicável.'
        Documentacao = 'https://learn.microsoft.com/graph/api/rbacapplication-list-roleassignmentscheduleinstances'
    }
}

$rows = @(
    $active | ForEach-Object { Convert-RoleRow -Item $_ -AssignmentMode 'Ativa' }
    $eligible | ForEach-Object { Convert-RoleRow -Item $_ -AssignmentMode 'Elegivel' }
)

Export-GraphCsv -Data $rows -Path (Join-Path $OutputDirectory 'funcoes-privilegiadas-pim.csv')
