# Inventário Completo de Recursos

## Objetivo

Inventariar os recursos disponíveis no Azure Resource Graph com informações técnicas, administrativas e de governança.

## Arquivo

- `query.kql`: consulta pronta para uso no Azure Resource Graph Explorer.

## Informações retornadas

- Nome e ID do recurso
- Tipo, Resource Group e localização
- Subscription ID e Subscription Name
- SKU, zonas e localização estendida
- Identidade gerenciada
- Recurso gerenciador
- Data e identidade de criação, quando expostas em `systemData`
- Última alteração, quando exposta em `systemData`
- Tags, plano e propriedades completas

## Filtrar por subscriptions

A consulta não possui subscriptions fixas. Para limitar o escopo, adicione a etapa abaixo imediatamente após `Resources`:

```kusto
| where subscriptionId in (
    'SUBSCRIPTION-ID-1',
    'SUBSCRIPTION-ID-2'
)
```

Também é possível selecionar as subscriptions diretamente no escopo do Azure Resource Graph Explorer.

## Observações

Alguns campos, principalmente `systemData`, identidade, SKU e plano, podem ficar vazios quando o provedor do recurso não os disponibiliza no Resource Graph. A coluna `Propriedades` pode aumentar consideravelmente o volume exportado; remova-a quando desejar um inventário mais leve.
