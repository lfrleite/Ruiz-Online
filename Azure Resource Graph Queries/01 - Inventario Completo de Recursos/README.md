# Inventário Completo de Recursos

## Objetivo

Inventariar os recursos disponíveis no Azure Resource Graph com informações técnicas, administrativas e de governança expostas pela tabela `Resources`.

## Arquivo

- `query.kql`: consulta pronta para uso no Azure Resource Graph Explorer.

## Informações retornadas

- Nome e ID do recurso
- Tipo, Resource Group e localização
- Subscription ID e Subscription Name
- SKU, zonas e localização estendida
- Identidade gerenciada
- Recurso gerenciador
- Plano do recurso
- Tags
- Propriedades completas retornadas pelo provedor

## Filtrar por subscriptions

A consulta não possui subscriptions fixas. Para limitar o escopo, adicione a etapa abaixo imediatamente após `Resources`:

```kusto
| where subscriptionId in (
    'SUBSCRIPTION-ID-1',
    'SUBSCRIPTION-ID-2'
)
```

Também é possível selecionar as subscriptions diretamente no escopo do Azure Resource Graph Explorer.

## Limitações

A tabela `Resources` não expõe de forma uniforme a data de criação, o criador ou a última identidade que modificou cada recurso. Essas informações não devem ser consultadas por `systemData` nesta query.

Para auditoria de criação e alteração, utilize as tabelas `resourcechanges` e `resourcecontainerchanges`, ou complemente a análise com o Azure Activity Log.

Campos dinâmicos como `sku`, `identity`, `plan`, `extendedLocation` e `properties` podem ficar vazios para tipos de recursos que não disponibilizam essas informações no Resource Graph.
