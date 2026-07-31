# Atribuições e Exceções do Azure Policy

## Objetivo

Inventariar atribuições, exceções, definições e iniciativas do Azure Policy em uma única visão.

## Fonte

`PolicyResources`

## Campos retornados

- Tipo do objeto de governança
- Nome e descrição
- Subscription e escopo
- Policy Definition associada
- Enforcement Mode
- Identidade gerenciada
- Categoria e expiração de exceções
- Metadados e parâmetros

## Execução

Execute no Azure Resource Graph Explorer, Azure CLI ou Azure PowerShell.

### Filtro opcional por subscription

```kusto
| where subscriptionId in~ (
    '00000000-0000-0000-0000-000000000000',
    '11111111-1111-1111-1111-111111111111'
)
```

## Limitações

Objetos aplicados em Management Groups podem não possuir `subscriptionId`. Os campos disponíveis variam conforme o tipo de objeto retornado.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática com base na estrutura pública de `PolicyResources`.
- Execução no tenant: **não realizada**
