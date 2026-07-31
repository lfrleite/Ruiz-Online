# Conformidade do Azure Policy

## Objetivo

Consolidar o estado de conformidade das atribuições do Azure Policy por subscription.

## Fonte

`PolicyResources`

## Campos retornados

- Nome e ID da subscription
- Nome e ID da atribuição
- Total de avaliações
- Recursos conformes e não conformes
- Recursos isentos, em conflito ou não iniciados
- Percentual de conformidade

## Execução

Execute no Azure Resource Graph Explorer, Azure CLI com `az graph query` ou Azure PowerShell com `Search-AzGraph`.

### Filtro opcional por subscription

O arquivo `query.kql` contém o bloco abaixo comentado no topo. Para ativá-lo, remova `//` e mantenha o filtro imediatamente após a linha `PolicyResources`:

```kusto
// Para filtrar por subscriptions, insira após a linha "PolicyResources":
// | where subscriptionId in (
//     'SUBSCRIPTION-ID-1',
//     'SUBSCRIPTION-ID-2'
// )
```

## Limitações

Os estados do Azure Policy podem conter múltiplas avaliações para o mesmo recurso conforme atribuições e definições diferentes. O percentual representa os registros retornados pela consulta e não substitui a visão oficial de compliance do portal.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática com base na estrutura pública de `PolicyResources`.
- Execução no tenant: **não realizada**
