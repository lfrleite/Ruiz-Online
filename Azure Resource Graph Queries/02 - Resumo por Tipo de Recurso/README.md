# Resumo por Tipo de Recurso

## Objetivo

Consolidar a quantidade de recursos por tipo e por subscription, oferecendo uma visão resumida do inventário Azure.

## Fonte

- `Resources`
- `ResourceContainers`, utilizada para obter o nome da subscription

## Campos retornados

- Nome da subscription
- ID da subscription
- Tipo do recurso
- Quantidade de recursos

## Execução

Execute o arquivo `query.kql` no Azure Resource Graph Explorer, Azure CLI com `az graph query` ou Azure PowerShell com `Search-AzGraph`.

### Filtro opcional por subscription

O arquivo `query.kql` contém o bloco abaixo comentado no topo. Para ativá-lo, remova `//` e mantenha o filtro imediatamente após a linha `Resources`:

```kusto
// Para filtrar por subscriptions, insira após a linha "Resources":
// | where subscriptionId in (
//     'SUBSCRIPTION-ID-1',
//     'SUBSCRIPTION-ID-2'
// )
```

## Limitações

A consulta realiza a contagem por subscription e tipo de recurso. Ela não calcula quantidade distinta de Resource Groups, localizações, SKUs ou estados de provisionamento.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática do agrupamento e alinhamento da documentação com a projeção atual.
- Execução no tenant: **não realizada**
