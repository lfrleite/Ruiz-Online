# VMs com Situação do Backup

## Objetivo

Correlacionar máquinas virtuais com itens protegidos em Recovery Services Vault e identificar a situação de proteção observável pelo Azure Resource Graph.

## Fonte

`Resources + RecoveryServicesResources`

## Campos retornados

- Subscription e Resource Group
- Nome, localização e sistema operacional da VM
- Estado de energia disponível
- Situação e saúde da proteção
- Status e data do último backup
- Política e cofre relacionados

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

A ausência de item correlacionado indica que a proteção não foi identificada na fonte consultada; não confirma isoladamente que a VM não possua outro mecanismo de backup. Permissões, tipo de workload e modelo de proteção podem afetar o resultado.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática da correlação por Resource ID.
- Execução no tenant: **não realizada**
