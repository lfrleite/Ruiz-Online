# Recursos Criados em Data Específica

## Objetivo

Localizar eventos de criação de recursos em uma data determinada, com identidade, operação e Resource ID registrados pelo Azure Resource Changes.

## Fonte

`ResourceChanges`

## Configuração da data

Altere as duas ocorrências de `datetime(2026-01-01)` no arquivo `query.kql` para a data desejada.

## Campos retornados

- Subscription e Resource Group
- Nome e tipo do recurso
- Data da criação em UTC
- Identidade e tipo de identidade
- Cliente de origem e operação
- Correlation ID e Resource ID

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

O Resource Changes possui retenção limitada e os campos de identidade podem estar vazios ou indicar uma identidade gerenciada. A consulta identifica eventos registrados como `Create`; não substitui o Activity Log para investigação completa.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática da estrutura de `ResourceChanges`.
- Execução no tenant: **não realizada**
