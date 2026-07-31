# Bancos PaaS

## Objetivo

Inventariar serviços de dados gerenciados no Azure e consolidar configurações de SKU, versão, rede, segurança, armazenamento, backup e alta disponibilidade disponíveis no Azure Resource Graph.

## Fonte

- `Resources`
- `ResourceContainers`, utilizada para obter o nome da subscription

## Serviços contemplados

- Azure SQL Server e Azure SQL Database
- Azure SQL Managed Instance
- Azure Database for PostgreSQL Flexible Server
- Azure Database for MySQL Flexible Server
- Azure Cosmos DB
- Azure Cache for Redis
- Azure Synapse Analytics
- Azure Databricks

## Principais campos retornados

- Subscription, Resource Group, nome, tipo e localização
- Serviço e servidor pai quando aplicável
- SKU, camada, capacidade e versão do mecanismo
- Estado e provisionamento
- Acesso público, TLS mínimo e configurações de criptografia
- Armazenamento, IOPS, throughput e crescimento automático
- Retenção de backup e redundância
- Alta disponibilidade, zona e configurações específicas do serviço
- Datas disponíveis, tags e Resource ID

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

- As propriedades não são uniformes entre os diferentes serviços de banco de dados.
- Campos vazios podem representar propriedade não aplicável ou não exposta pela versão da API.
- A consulta não retorna métricas de desempenho, consumo, conexões, tamanho realmente utilizado ou custo.
- Recomendações de segurança e dimensionamento devem ser confirmadas com métricas e documentação do serviço.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática dos tipos de recurso e grupos de propriedades projetados.
- Execução no tenant: **não realizada**
