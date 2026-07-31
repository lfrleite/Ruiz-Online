# Retirements e Recursos Impactados

## Objetivo

Correlacionar avisos de retirada ou descontinuação publicados pelo Azure Service Health com os recursos impactados disponibilizados pela plataforma.

## Fonte

`ServiceHealthResources`

## Campos retornados

- Subscription
- Tracking ID
- Título, resumo e status do evento
- Datas de início, mitigação e atualização
- Resource ID e tipo do recurso impactado
- Região e status do impacto

## Execução

Execute no Azure Resource Graph Explorer, Azure CLI ou Azure PowerShell.

### Filtro opcional por subscription

O arquivo `query.kql` contém o bloco abaixo comentado no topo. Para ativá-lo, remova `//` e mantenha o filtro imediatamente após a linha `ServiceHealthResources`:

```kusto
// Para filtrar por subscriptions, insira após a linha "ServiceHealthResources":
// | where subscriptionId in (
//     'SUBSCRIPTION-ID-1',
//     'SUBSCRIPTION-ID-2'
// )
```

## Limitações

A disponibilidade de recursos impactados não é completa para todos os retirements. O filtro textual considera termos comuns em inglês e português e pode exigir ajuste conforme o conteúdo publicado no evento. Para alguns serviços, o Azure Advisor pode fornecer detalhes complementares.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática com base na estrutura pública de `ServiceHealthResources`.
- Execução no tenant: **não realizada**
