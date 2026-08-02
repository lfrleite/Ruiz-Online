param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'output')
)

. (Join-Path $PSScriptRoot '..\_Common\GraphHelpers.ps1')
Connect-GraphForScopes -Scopes @('AuditLog.Read.All')

$details = Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/reports/authenticationMethods/userRegistrationDetails?$top=999'

$rows = foreach ($user in $details) {
    [pscustomobject]@{
        UserId = $user.id
        UserPrincipalName = $user.userPrincipalName
        UserDisplayName = $user.userDisplayName
        UserType = $user.userType
        IsAdmin = $user.isAdmin
        IsMfaRegistered = $user.isMfaRegistered
        IsMfaCapable = $user.isMfaCapable
        IsSsprRegistered = $user.isSsprRegistered
        IsSsprCapable = $user.isSsprCapable
        IsPasswordlessCapable = $user.isPasswordlessCapable
        MethodsRegistered = ($user.methodsRegistered -join '; ')
        DefaultMfaMethod = $user.defaultMfaMethod
        SystemPreferredAuthenticationMethods = ($user.systemPreferredAuthenticationMethods -join '; ')
        Recomendacao = if ($user.isAdmin -and -not $user.isMfaCapable) { 'Prioridade: administrador sem capacidade de MFA.' } elseif (-not $user.isMfaCapable) { 'Registrar método forte de MFA.' } elseif (-not $user.isSsprCapable) { 'Concluir registro para SSPR.' } else { 'Sem alerta inicial.' }
        Causa = if (-not $user.isMfaCapable) { 'O relatório indica que o usuário não está apto a concluir MFA.' } elseif (-not $user.isSsprCapable) { 'O relatório indica que o usuário não está apto a utilizar SSPR.' } else { 'Registro compatível com os indicadores avaliados.' }
        Solucao = 'Orientar registro de métodos permitidos, revisar política de métodos e priorizar administradores.'
        Documentacao = 'https://learn.microsoft.com/graph/api/authenticationmethodsroot-list-userregistrationdetails'
    }
}

Export-GraphCsv -Data @($rows) -Path (Join-Path $OutputDirectory 'mfa-sspr-metodos.csv')
