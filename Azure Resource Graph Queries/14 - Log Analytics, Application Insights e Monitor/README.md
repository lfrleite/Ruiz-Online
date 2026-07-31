# Log Analytics, Application Insights e Monitor

## Objetivo

Inventariar recursos de observabilidade do Azure, consolidando workspaces, tabelas, Application Insights, Data Collection Rules e Action Groups com suas principais configurações.

## Fonte

- `Resources`
- `ResourceContainers`, utilizada para obter o nome da subscription

## Recursos contemplados

- Log Analytics Workspaces
- Tabelas do Log Analytics
- Application Insights
- Data Collection Rules
- Action Groups

## Principais campos retornados

- Subscription, Resource Group, nome, tipo e localização
- Workspace e tabela relacionados
- SKU, retenção, plano da tabela e quota diária
- Acesso público para ingestão e consulta
- Application Insights, workspace associado e modo de ingestão
- Data sources, destinations e data flows de DCRs
- Configuração e receptores de Action Groups
- Estado de provisionamento, datas disponíveis, tags e Resource ID

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

- A consulta mostra configurações ARM e não retorna volume de ingestão, consultas, falhas, alertas disparados ou custo.
- Campos dinâmicos de DCRs e Action Groups podem exigir expansão para análise individual.
- A associação entre recursos de monitoramento pode depender de IDs armazenados em propriedades específicas.
- `systemData` pode não estar disponível de forma uniforme.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática dos tipos de observabilidade e propriedades projetadas.
- Execução no tenant: **não realizada**
