# Recursos de Rede com Impacto Financeiro

## Objetivo

Inventariar recursos de rede que normalmente possuem cobrança própria ou influência relevante no custo da arquitetura, consolidando configurações técnicas e possíveis pontos de revisão.

## Fonte

- `Resources`
- `ResourceContainers`, utilizada para obter o nome da subscription

## Recursos contemplados

- Azure Firewall
- Application Gateway
- Load Balancer
- Public IP Address
- NAT Gateway
- Virtual Network Gateway
- ExpressRoute Circuit
- Azure Bastion
- CDN e Azure Front Door
- Private Endpoint
- Private DNS Zone

## Principais campos retornados

- Subscription, Resource Group, nome, tipo e localização
- SKU, camada, zonas e estado de provisionamento
- Configurações específicas de firewall, gateway, balanceador, NAT, ExpressRoute, Bastion e Front Door
- Endereços públicos e associações
- Backend pools, listeners, regras e configurações de rede
- Indicadores de associação e recomendações iniciais
- Tags e Resource ID

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

- A consulta não retorna custo, consumo, tráfego ou métricas de utilização.
- Um recurso aparentemente sem associação deve ser validado antes de qualquer remoção.
- Campos dinâmicos podem exigir expansão para análise de regras e associações individuais.
- A classificação de impacto financeiro é conceitual e não substitui Cost Management.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática dos tipos de recurso e propriedades projetadas.
- Execução no tenant: **não realizada**
