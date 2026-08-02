# Jobs de Backup com Falha

## Objetivo

Listar jobs de backup com falha, conclusão parcial ou avisos em Recovery Services Vaults e Backup Vaults.

## Fonte

`RecoveryServicesResources`

## Campos retornados

- Subscription e cofre
- Recurso ou entidade protegida
- Tipo de carga
- Operação e status
- Datas de início e término
- Código e detalhes do erro

## Execução

Execute no Azure Resource Graph Explorer, Azure CLI ou Azure PowerShell.

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

O Azure Backup disponibiliza no ARG apenas os jobs recentes, normalmente até 14 dias. Para histórico ampliado, utilize Azure Monitor Logs, Backup Reports ou outra fonte de retenção.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática com base na estrutura pública de `RecoveryServicesResources`.
- Execução no tenant: **não realizada**
