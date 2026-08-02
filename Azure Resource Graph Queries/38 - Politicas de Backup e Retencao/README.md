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

O arquivo `query.kql` contém o bloco abaixo comentado no topo. Para ativá-lo, remova `//` e mantenha o filtro imediatamente após a linha `RecoveryServicesResources`:

```kusto
// Para filtrar por subscriptions, insira após a linha "RecoveryServicesResources":
// | where subscriptionId in (
//     'SUBSCRIPTION-ID-1',
//     'SUBSCRIPTION-ID-2'
// )
```

## Limitações

As estruturas de agenda e retenção diferem entre Recovery Services e Data Protection. Por isso, os objetos originais são preservados em formato textual para análise posterior.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática com base na estrutura pública de `RecoveryServicesResources`.
- Execução no tenant: **não realizada**
