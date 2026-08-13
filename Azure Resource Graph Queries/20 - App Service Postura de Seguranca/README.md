# App Service — Postura de Segurança

## Objetivo

Avaliar configurações de segurança e exposição de Azure App Service sem misturar regras de lifecycle de runtimes que envelhecem com o tempo.

## Fonte

`AppServiceResources` + `Resources`

## Campos retornados

- Subscription, Resource Group e App Service
- TLS mínimo e classificação inicial
- HTTPS Only
- Estado de FTP/FTPS
- Remote Debugging
- HTTP/2 e Always On
- Public Network Access e VNet Integration
- App Service Plan
- Versões de runtime reportadas pelo recurso

## Execução

Execute no Azure Resource Graph Explorer, Azure CLI ou Azure PowerShell.

### Filtro opcional por subscription

O arquivo `query.kql` contém um bloco comentado imediatamente após `AppServiceResources`. Remova `//` para restringir a subscriptions específicas.

## Limitações

A consulta classifica apenas configurações observáveis no ARM. Versões de runtime são retornadas como inventário e não recebem classificação de suporte ou retirement; para isso, utilize Service Health, Azure Advisor e a matriz oficial de suporte vigente. Algumas propriedades podem variar conforme plataforma, sistema operacional, SKU e modelo de hospedagem.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **13/08/2026**
- Evidência: uso de `AppServiceResources` alinhado aos exemplos oficiais do Azure Resource Graph para `microsoft.web/sites/config`.
- Execução no tenant: **não realizada**
