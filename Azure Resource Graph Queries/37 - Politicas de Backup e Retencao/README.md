# Políticas de Backup e Retenção

## Objetivo

Inventariar políticas de Recovery Services Vault e Backup Vault, incluindo agenda, retenção e quantidade de itens associados.

## Fonte

`RecoveryServicesResources`

## Campos retornados

- Subscription, cofre e política
- Tipo de política e carga protegida
- Timezone e agenda
- Configuração de retenção
- Estado de provisionamento
- Quantidade de itens protegidos associados

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

As estruturas de agenda e retenção diferem entre Recovery Services e Data Protection. Por isso, os objetos originais são preservados em formato textual para análise posterior.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática com base na estrutura pública de `RecoveryServicesResources`.
- Execução no tenant: **não realizada**
