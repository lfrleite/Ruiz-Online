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

```kusto
| where subscriptionId in~ (
    '00000000-0000-0000-0000-000000000000',
    '11111111-1111-1111-1111-111111111111'
)
```

## Limitações

O Azure Backup disponibiliza no ARG apenas os jobs recentes, normalmente até 14 dias. Para histórico ampliado, utilize Azure Monitor Logs, Backup Reports ou outra fonte de retenção.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática com base na estrutura pública de `RecoveryServicesResources`.
- Execução no tenant: **não realizada**
