# App Services, Functions e Runtimes

## Objetivo

Inventariar App Services, Function Apps, Logic Apps Standard, API Apps e slots, correlacionando cada workload ao App Service Plan e às configurações de runtime expostas pelo Azure Resource Graph.

## Fonte

- `Resources`
- `AppServiceResources`
- `ResourceContainers`, utilizada para obter o nome da subscription

## Principais campos retornados

- Subscription, Resource Group, nome, tipo e localização
- Aplicação principal e nome do slot
- App Service Plan, SKU, capacidade e sistema operacional do plano
- Estado, disponibilidade e hostname padrão
- Runtimes Linux, Windows, .NET, Java, PHP, Python, Node.js e PowerShell
- Always On, HTTP/2, WebSockets e health check
- Identidade gerenciada
- Datas disponíveis, tags e Resource ID

## Execução

Execute o arquivo `query.kql` no Azure Resource Graph Explorer, Azure CLI com `az graph query` ou Azure PowerShell com `Search-AzGraph`.

### Filtro opcional por subscription

O arquivo `query.kql` contém um bloco comentado no topo. Para ativá-lo, remova `//` e mantenha o filtro imediatamente após a linha `Resources`.

## Separação de responsabilidades

Esta consulta é deliberadamente um **inventário de workloads e runtimes**. Ela não classifica versões como suportadas, legadas ou em retirement, pois esse estado muda ao longo do tempo e deve ser validado contra fontes vigentes.

Para postura de segurança de App Service, utilize a consulta **20 - App Service Postura de Segurança**. Para retirements e impactos anunciados pela plataforma, utilize as consultas de Service Health/Advisor apropriadas.

## Limitações

- A disponibilidade das propriedades varia conforme Windows, Linux, Function App, Logic App e slot.
- A consulta mostra a configuração declarada no ARM e não confirma o runtime efetivamente carregado pela aplicação.
- Métricas, logs, falhas de aplicação e volume de requisições exigem Azure Monitor ou Application Insights.
- A identificação de versões em fim de suporte deve ser validada com documentação vigente do runtime e comunicações oficiais da plataforma.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **13/08/2026**
- Evidência: consulta refatorada para usar `AppServiceResources` nas configurações de runtime e remover classificações de lifecycle hardcoded.
- Execução no tenant: **não realizada**
