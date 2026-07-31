# App Services, Functions e Runtimes

## Objetivo

Inventariar App Services, Function Apps, Logic Apps Standard, API Apps e slots, correlacionando cada workload ao App Service Plan e expondo configurações de runtime, segurança, rede e disponibilidade.

## Fonte

- `Resources`
- `ResourceContainers`, utilizada para obter o nome da subscription

## Principais campos retornados

- Subscription, Resource Group, nome, tipo e localização
- Aplicação principal e nome do slot
- App Service Plan, SKU, capacidade, sistema operacional e workers
- Estado, disponibilidade e hostname padrão
- HTTPS Only, TLS mínimo, acesso público e certificados de cliente
- VNet Integration e Route All
- Runtimes Linux, Windows, .NET, Java, PHP, Python, Node.js e PowerShell
- Always On, HTTP/2, FTP state e health check
- Configurações de escala, identidade e diagnóstico
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

- A disponibilidade das propriedades varia conforme Windows, Linux, Function App, Logic App e slot.
- A consulta mostra a configuração declarada no ARM e não confirma o runtime efetivamente carregado pela aplicação.
- Métricas, logs, falhas de aplicação e volume de requisições exigem Azure Monitor ou Application Insights.
- A identificação de versões em fim de suporte deve ser validada com a documentação vigente do runtime.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática dos tipos de workload, correlação com planos e propriedades projetadas.
- Execução no tenant: **não realizada**
