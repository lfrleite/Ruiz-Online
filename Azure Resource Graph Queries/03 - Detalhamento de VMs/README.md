# Detalhamento de Virtual Machines

## Objetivo

Inventariar máquinas virtuais do Azure com informações de configuração, sistema operacional, licenciamento, segurança, armazenamento, rede, identidade e estado operacional disponíveis no Azure Resource Graph.

## Fonte

- `Resources`
- `ResourceContainers`, utilizada para obter o nome da subscription

## Principais campos retornados

- Subscription, Resource Group, nome, localização e Resource ID
- Tamanho da VM, zonas, prioridade e estado de provisionamento
- Estado de energia e informações de instance view quando disponíveis
- Sistema operacional, versão, imagem, publisher, offer, SKU e versão
- `licenseType` e indicação de Azure Hybrid Benefit
- Security Type, Secure Boot e vTPM
- Disco do sistema operacional e discos de dados
- Interfaces de rede, IPs, subnets e NSGs associados
- Diagnóstico de boot
- Identidade gerenciada
- Plano de marketplace e configurações adicionais expostas pelo provedor
- Tags

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

- Alguns campos dependem da versão da API e da disponibilidade das propriedades no Resource Graph.
- Informações internas do sistema operacional convidado não são coletadas diretamente pela consulta.
- Estado de energia e instance view podem ficar vazios para determinadas VMs ou escopos.
- A consulta não substitui Azure Monitor, Azure Policy Guest Configuration ou comandos executados dentro da VM.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática da estrutura e dos grupos de propriedades projetados.
- Execução no tenant: **não realizada**
