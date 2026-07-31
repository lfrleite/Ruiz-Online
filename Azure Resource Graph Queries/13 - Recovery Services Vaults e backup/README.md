# Recovery Services Vaults e Backup

## Objetivo

Inventariar cofres, itens protegidos, instâncias de backup e políticas do Azure Backup e Azure Data Protection, consolidando estado de proteção, último backup, retenção, criptografia e controles de segurança disponíveis no Azure Resource Graph.

## Fonte

- `RecoveryServicesResources`
- `ResourceContainers`, utilizada para obter o nome da subscription

## Recursos contemplados

- Recovery Services Vaults
- Backup Vaults
- Protected Items
- Backup Instances
- Backup Policies

## Principais campos retornados

- Subscription, Resource Group, cofre, tipo e localização
- SKU e estado de provisionamento
- Tipo de gerenciamento, workload e datasource
- Recurso protegido, nome amigável e política associada
- Estado e saúde da proteção
- Status e horário do último backup
- Recovery Points disponíveis
- Soft Delete, imutabilidade e criptografia
- Agenda e retenção das políticas
- Recomendações iniciais, datas disponíveis, tags e Resource ID

## Execução

Execute o arquivo `query.kql` no Azure Resource Graph Explorer, Azure CLI com `az graph query` ou Azure PowerShell com `Search-AzGraph`.

### Filtro opcional por subscription

O arquivo `query.kql` contém o bloco abaixo comentado no topo. Para ativá-lo, remova `//` e mantenha o filtro imediatamente após a linha `RecoveryServicesResources`:

```kusto
// Para filtrar por subscriptions, insira após a linha "RecoveryServicesResources":
// | where subscriptionId in (
//     'SUBSCRIPTION-ID-1',
//     'SUBSCRIPTION-ID-2'
// )
```

## Limitações

- As propriedades variam entre Recovery Services e Data Protection.
- Campos vazios podem indicar informação não aplicável ou não exposta pela API.
- A consulta mostra o inventário e o estado conhecido, mas não substitui testes de restauração.
- Jobs históricos e relatórios de longo prazo exigem consultas específicas ou Azure Monitor Logs.
- `systemData` pode não estar disponível de forma uniforme.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática dos tipos de backup e propriedades projetadas.
- Execução no tenant: **não realizada**
