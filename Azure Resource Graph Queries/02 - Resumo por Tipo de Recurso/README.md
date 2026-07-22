# Resumo por Tipo de Recurso

## Objetivo

Consolidar a quantidade de recursos por tipo e por subscription, facilitando a leitura executiva do inventário Azure.

## Arquivo

- `query.kql`: consulta pronta para uso no Azure Resource Graph Explorer.

## Informações retornadas

- Subscription Name
- Subscription ID
- Tipo de recurso
- Quantidade total de recursos
- Quantidade distinta de Resource Groups
- Quantidade distinta de localizações

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

O nome da subscription é obtido dinamicamente na tabela `ResourceContainers`, evitando a manutenção de mapeamentos manuais entre nomes e IDs.
