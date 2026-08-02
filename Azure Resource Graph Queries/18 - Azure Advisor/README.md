# Azure Advisor

## Objetivo

Consolidar recomendações do Azure Advisor por categoria, impacto, recurso afetado e orientação de remediação.

## Fonte

`AdvisorResources`

## Campos retornados

- Subscription
- Categoria e impacto
- Problema e solução
- Resource ID afetado
- Campo e valor impactados
- Última atualização
- Propriedades adicionais da recomendação

## Execução

Execute no Azure Resource Graph Explorer, Azure CLI ou Azure PowerShell.

### Filtro opcional por subscription

O arquivo `query.kql` contém o bloco abaixo comentado no topo. Para ativá-lo, remova `//` e mantenha o filtro imediatamente após a linha `AdvisorResources`:

```kusto
// Para filtrar por subscriptions, insira após a linha "AdvisorResources":
// | where subscriptionId in (
//     'SUBSCRIPTION-ID-1',
//     'SUBSCRIPTION-ID-2'
// )
```

## Limitações

Os campos adicionais variam conforme a categoria e o tipo da recomendação. A implementação deve considerar contexto técnico, utilização real, custos e impacto operacional.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática com base na estrutura pública de `AdvisorResources`.
- Execução no tenant: **não realizada**
