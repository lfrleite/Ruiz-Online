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

```kusto
| where subscriptionId in~ (
    '00000000-0000-0000-0000-000000000000',
    '11111111-1111-1111-1111-111111111111'
)
```

## Limitações

Os campos adicionais variam conforme a categoria e o tipo da recomendação. A implementação deve considerar contexto técnico, utilização real, custos e impacto operacional.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática com base na estrutura pública de `AdvisorResources`.
- Execução no tenant: **não realizada**
