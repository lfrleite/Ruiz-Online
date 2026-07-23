# Detalhamento de Virtual Machines

## Objetivo

Relacionar cada VM no Azure com suas informações devidamente detalhadas.

## Arquivo

- `query.kql`: consulta pronta para uso no Azure Resource Graph Explorer.

## Filtrar por subscriptions

A consulta não possui subscriptions fixas. Para limitar o escopo, adicione a etapa abaixo imediatamente após `Resources`:

```kusto
| where subscriptionId in (
    'SUBSCRIPTION-ID-1',
    'SUBSCRIPTION-ID-2'
)
```

Também é possível selecionar as subscriptions diretamente no escopo do Azure Resource Graph Explorer.
