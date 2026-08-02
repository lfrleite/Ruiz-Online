param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'output')
)

. (Join-Path $PSScriptRoot '..\_Common\GraphHelpers.ps1')
Connect-GraphForScopes -Scopes @('Organization.Read.All','OrganizationalBranding.Read.All')

$organization = (Invoke-GraphPagedRequest -Uri 'https://graph.microsoft.com/v1.0/organization?$select=id,displayName,verifiedDomains')[0]
$branding = $null
$brandingConfigured = $true

try {
    $branding = (Invoke-GraphPagedRequest -Uri "https://graph.microsoft.com/v1.0/organization/$($organization.id)/branding")[0]
}
catch {
    $brandingConfigured = $false
}

$rows = foreach ($domain in $organization.verifiedDomains) {
    [pscustomobject]@{
        TenantId = $organization.id
        Organizacao = $organization.displayName
        Dominio = $domain.name
        Default = $domain.isDefault
        Initial = $domain.isInitial
        Verified = $domain.isVerified
        Type = $domain.type
        Capabilities = ConvertTo-CompactJson $domain.capabilities
        BrandingConfigurado = $brandingConfigured
        SignInPageText = $branding.signInPageText
        UsernameHintText = $branding.usernameHintText
        BackgroundColor = $branding.backgroundColor
        Recomendacao = if (-not $brandingConfigured) { 'Avaliar branding organizacional da página de entrada.' } elseif (-not $domain.isVerified) { 'Concluir verificação do domínio ou remover configuração obsoleta.' } else { 'Manter revisão de domínios e identidade visual.' }
        Causa = if (-not $brandingConfigured) { 'A API não retornou branding padrão configurado.' } else { 'Estado retornado pelo Microsoft Graph.' }
        Solucao = 'Configurar branding aprovado e revisar domínio padrão, inicial e domínios não utilizados.'
        Documentacao = 'https://learn.microsoft.com/graph/api/organizationalbranding-get'
    }
}

Export-GraphCsv -Data @($rows) -Path (Join-Path $OutputDirectory 'branding-dominios.csv')
