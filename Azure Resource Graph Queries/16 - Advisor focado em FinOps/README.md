# Advisor focado em FinOps

## Objetivo

Consolidar recomendações da categoria de custo do Azure Advisor sem limitar a consulta a subscriptions específicas.

## Fonte

`AdvisorResources`

## Campos retornados

- Nome e ID da subscription
- Categoria e impacto
- Problema e solução
- Recurso impactado
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

A economia estimada e os campos adicionais não possuem estrutura uniforme para todas as recomendações. A implementação deve considerar criticidade, utilização real e contexto de negócio.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática com base na estrutura pública de `AdvisorResources`.
- Execução no tenant: **não realizada**
