# Recursos por BU e Tags

## Objetivo

Relacionar cada recurso Azure às principais tags de negócio, operação, FinOps e governança.

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

## Observações

Os nomes das tags são avaliados conforme a grafia padronizada em letras maiúsculas. Variações como `bu`, `Bu` ou nomes com espaços serão tratadas como chaves diferentes pelo Azure.
