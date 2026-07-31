# Eventos Ativos do Service Health

## Objetivo

Listar eventos ativos do Azure Service Health, incluindo problemas de serviço, manutenções, avisos de integridade e avisos de segurança.

## Fonte

`ServiceHealthResources`

## Campos retornados

- Subscription
- Tipo, nível e status do evento
- Título e resumo
- Tracking ID
- Início do impacto e previsão de mitigação
- Última atualização
- Serviços impactados

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

Problemas emergentes que ainda não estejam vinculados a subscriptions podem não ser retornados pelo ARG. A disponibilidade dos campos varia conforme o tipo do evento.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática com base na estrutura pública de `ServiceHealthResources`.
- Execução no tenant: **não realizada**
