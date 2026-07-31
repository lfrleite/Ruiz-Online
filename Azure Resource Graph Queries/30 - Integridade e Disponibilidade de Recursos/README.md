# Integridade e Disponibilidade de Recursos

## Objetivo

Listar o estado de disponibilidade reportado pelo Azure Resource Health e correlacioná-lo com o inventário do recurso.

## Fonte

`HealthResources + Resources`

## Campos retornados

- Subscription e Resource Group
- Nome, tipo e localização do recurso
- Estado de disponibilidade
- Resumo, motivo e cronicidade
- Datas de ocorrência e reporte
- Estimativa de resolução, quando disponível

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

O Azure Resource Health não oferece cobertura idêntica para todos os tipos de recurso. Campos de motivo e resolução podem estar vazios conforme o evento e o provedor.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática com base na estrutura pública de `HealthResources`.
- Execução no tenant: **não realizada**
