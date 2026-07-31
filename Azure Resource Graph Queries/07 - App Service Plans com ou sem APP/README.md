# App Service Plans com ou sem APP

## Objetivo

Inventariar App Service Plans, correlacionar aplicações e slots associados e identificar planos que podem estar sem workloads.

## Fonte

- `Resources`
- `ResourceContainers`, utilizada para obter o nome da subscription

## Principais campos retornados

- Subscription, Resource Group, nome, localização e Resource ID
- SKU, camada, tamanho, família e capacidade
- Sistema operacional do plano
- Quantidade de apps, slots e workloads associados
- Lista de aplicações, tipos, estados e hostnames
- Estado de provisionamento
- Configurações de escala, workers, zonas e App Service Environment
- Indicador de possível plano vazio
- Recomendação inicial de revisão
- Tags e datas disponíveis

## Execução

Execute o arquivo `query.kql` no Azure Resource Graph Explorer, Azure CLI com `az graph query` ou Azure PowerShell com `Search-AzGraph`.

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

- Um plano sem apps ou slots deve ser tratado como candidato à revisão, não como autorização automática para exclusão.
- A correlação depende de `properties.serverFarmId` e pode não contemplar recursos removidos, inconsistentes ou ainda em provisionamento.
- Métricas reais de CPU, memória, requisições e utilização não são fornecidas pelo Azure Resource Graph.
- `systemData` pode não estar disponível de forma uniforme.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática dos joins, contagens e campos projetados.
- Execução no tenant: **não realizada**
