# Public IPs e NICs Órfãos

## Objetivo

Inventariar Public IP Addresses e Network Interfaces, identificar associações conhecidas e sinalizar candidatos a recursos sem vínculo aparente.

## Fonte

- `Resources`
- `ResourceContainers`, utilizada para obter o nome da subscription

## Principais campos retornados

- Subscription, Resource Group, nome, tipo e localização
- SKU, camada, zonas e estado de provisionamento
- Endereço IP, método de alocação, versão, DNS e timeout
- Associação do Public IP a configuração de IP, NAT Gateway ou Private Link Service
- Associação da NIC a VM ou Private Endpoint
- NSG, MAC address, IP forwarding e Accelerated Networking
- IP privado principal, subnet e Public IP associados à NIC
- Indicador de candidato órfão
- Status de associação e recomendação inicial
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

- O indicador órfão considera as associações expostas no ARM e deve ser tratado como candidato à investigação.
- Dependências indiretas, automações, recursos temporários ou estados de transição podem não aparecer na consulta.
- A ausência de NSG na NIC não significa necessariamente ausência de controle, pois o NSG pode estar associado à subnet.
- A consulta não mede tráfego, utilização ou custo.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática das associações e classificações projetadas.
- Execução no tenant: **não realizada**
