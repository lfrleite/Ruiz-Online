# Discos Gerenciados

## Objetivo

Inventariar discos gerenciados do Azure, identificar associação com recursos, estado do disco, características técnicas, datas disponíveis e possíveis candidatos a disco não anexado.

## Fonte

- `Resources`
- `ResourceContainers`, utilizada para obter o nome da subscription

## Principais campos retornados

- Subscription, Resource Group, nome, localização e Resource ID
- SKU, tamanho e sistema operacional
- Estado do disco e recurso associado por `managedBy`
- Indicador de possível disco não anexado
- Opção e origem de criação
- Criptografia e Disk Encryption Set
- Configurações de acesso de rede
- Data de criação exposta pelo recurso, `systemData` e tags alternativas quando disponíveis
- Idade estimada do disco
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

- Um disco sem `managedBy` deve ser tratado como candidato à revisão, não como autorização automática para exclusão.
- Campos de criação e `systemData` podem não estar disponíveis de forma uniforme.
- A consulta não valida dependências externas, snapshots, processos de restore, replicação ou requisitos de retenção.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática dos campos de associação e configuração.
- Execução no tenant: **não realizada**
