# Inventário de Azure Virtual Desktop

## Objetivo

Inventariar os principais recursos ARM do Azure Virtual Desktop: Host Pools, Workspaces, Application Groups e Scaling Plans.

## Fonte

`Resources`

## Campos retornados

- Subscription e Resource Group
- Tipo e nome do recurso AVD
- Configurações do Host Pool
- Limite de sessões e Start VM on Connect
- Associações de Application Groups e Workspaces
- Configurações e referências de Scaling Plans

## Execução

Execute no Azure Resource Graph Explorer, Azure CLI ou Azure PowerShell.

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

O ARG fornece o inventário dos recursos ARM, mas não garante os detalhes operacionais dos Session Hosts, como heartbeat, Agent Version, Allow New Session e sessões ativas. Para isso, utilize a API de Desktop Virtualization.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática das propriedades públicas do Azure Virtual Desktop no ARG.
- Execução no tenant: **não realizada**
