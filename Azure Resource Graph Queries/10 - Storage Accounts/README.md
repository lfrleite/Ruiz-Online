# Storage Accounts

## Objetivo

Inventariar Storage Accounts e expor configurações de SKU, redundância, segurança, rede, criptografia e recursos avançados disponíveis no Azure Resource Graph.

## Fonte

- `Resources`
- `ResourceContainers`, utilizada para obter o nome da subscription

## Principais campos retornados

- Subscription, Resource Group, nome, localização e Resource ID
- Tipo do Storage Account, SKU, camada de acesso e redundância
- Estado das localizações primária e secundária
- HTTPS obrigatório e versão mínima de TLS
- Acesso público a blobs, Shared Key, OAuth padrão e replicação entre tenants
- Acesso público de rede, regras de IP e regras de rede virtual
- Private Endpoints
- Criptografia por serviço e infraestrutura
- Hierarchical Namespace, NFS, SFTP e Large File Shares
- Imutabilidade, datas disponíveis e tags
- Indicadores e recomendações iniciais de revisão

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

- A consulta apresenta configurações ARM e não retorna capacidade utilizada, transações, egress, disponibilidade ou custo.
- Regras de rede serializadas em campos dinâmicos podem exigir expansão adicional para análise individual.
- `systemData` pode não ser preenchido para todos os recursos.
- As recomendações devem ser validadas conforme requisitos de negócio e compatibilidade das aplicações.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática das propriedades de segurança, rede e armazenamento projetadas.
- Execução no tenant: **não realizada**
