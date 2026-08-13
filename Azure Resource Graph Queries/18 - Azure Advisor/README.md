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

O arquivo `query.kql` contém um bloco comentado no topo. Para ativá-lo, remova `//` e mantenha o filtro imediatamente após a linha `AdvisorResources`.

### Filtros opcionais por categoria

A consulta é intencionalmente geral. Para reproduzir uma visão especializada sem manter queries duplicadas, acrescente após o filtro de tipo uma das condições abaixo:

```kusto
| where tostring(properties.category) =~ 'Cost'
```

Outras categorias usuais podem ser filtradas pelo mesmo campo, conforme os valores retornados pelo Advisor no tenant.

## Limitações

Os campos adicionais variam conforme a categoria e o tipo da recomendação. Recomendações de custo não substituem Cost Management, dados de utilização, reservas ou Savings Plans. A implementação deve considerar contexto técnico, utilização real, custos e impacto operacional.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **13/08/2026**
- Evidência: revisão estática com base na estrutura pública de `AdvisorResources`; consulta de custo consolidada nesta entrada para eliminar duplicidade funcional.
- Execução no tenant: **não realizada**
