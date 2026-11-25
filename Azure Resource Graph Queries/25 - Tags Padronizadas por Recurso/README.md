# 25 - Tags Padronizadas por Recurso

## Objetivo

Inventariar tags comuns de governança em colunas separadas, sem depender de convenções de uma organização específica.

## Fonte

`Resources` e `ResourceContainers`.

## Campos retornados

Subscription, grupo de recursos, nome, tipo, localização, Environment, Owner, CostCenter, Application, Criticality, quantidade de campos sem valor, tags originais e Resource ID.

## Execução

Execute `query.kql` no Azure Resource Graph Explorer, Azure CLI ou Azure PowerShell.

```kusto
// Para filtrar por subscriptions, insira após a linha "Resources":
// | where subscriptionId in (
//     'SUBSCRIPTION-ID-1',
//     'SUBSCRIPTION-ID-2'
// )
```

## Limitações

- As cinco tags são exemplos genéricos, não uma política obrigatória universal.
- As variantes de chaves são explícitas; outras convenções devem ser adaptadas pelo usuário.
- Valores vazios não comprovam não conformidade com Azure Policy.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **25/11/2026**
- Evidência: revisão estática da projeção e classificação de tags.
- Execução no tenant: **não realizada**
