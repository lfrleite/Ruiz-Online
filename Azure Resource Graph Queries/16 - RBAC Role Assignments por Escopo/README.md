# RBAC — Role Assignments por Escopo

## Objetivo

Inventariar atribuições de funções do Azure RBAC, correlacionando principal, função e escopo para apoiar revisões de governança e privilégio.

## Fonte

`AuthorizationResources`

## Campos retornados

- Subscription
- Nome e tipo da função
- Principal ID e tipo do principal
- Tipo e caminho do escopo
- Condição e versão da condição
- Escopos atribuíveis da role definition
- ID da atribuição

## Execução

Execute no Azure Resource Graph Explorer, Azure CLI ou Azure PowerShell.

### Filtro opcional por subscription

O arquivo `query.kql` contém um bloco comentado imediatamente após `AuthorizationResources`. Remova `//` para restringir a subscriptions específicas.

## Limitações

O Azure Resource Graph retorna IDs e tipos dos principals, mas não resolve nomes de usuários, grupos ou service principals. Para enriquecimento de identidade, utilize Microsoft Graph. A consulta também não determina sozinha se uma permissão é excessiva; essa avaliação depende do contexto do workload.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **13/08/2026**
- Evidência: estrutura baseada em `AuthorizationResources` e exemplos oficiais do Azure Resource Graph.
- Execução no tenant: **não realizada**
