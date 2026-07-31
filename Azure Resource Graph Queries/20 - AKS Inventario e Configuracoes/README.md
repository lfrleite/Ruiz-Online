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

```kusto
| where subscriptionId in~ (
    '00000000-0000-0000-0000-000000000000',
    '11111111-1111-1111-1111-111111111111'
)
```

## Limitações

O ARG retorna a configuração ARM do cluster, mas não substitui consultas ao Kubernetes API Server para workloads, namespaces, imagens, requests, limits ou estado dos pods.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática das propriedades públicas de `Microsoft.ContainerService/managedClusters`.
- Execução no tenant: **não realizada**
