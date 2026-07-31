# AKS — Inventário e Configurações

## Objetivo

Inventariar clusters Azure Kubernetes Service e as principais configurações expostas pelo Azure Resource Graph.

## Fonte

`Resources`

## Campos retornados

- Subscription, Resource Group e cluster
- Versão do Kubernetes
- Cluster privado e acesso à API
- Configurações de rede
- Identidade e integração com Microsoft Entra ID
- Node pools
- Canais de atualização
- OIDC, Workload Identity, Defender, Azure Policy e monitoramento

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

O ARG retorna a configuração ARM do cluster, mas não substitui consultas ao Kubernetes API Server para workloads, namespaces, imagens, requests, limits ou estado dos pods.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática das propriedades públicas de `Microsoft.ContainerService/managedClusters`.
- Execução no tenant: **não realizada**
