# Configurações e Atribuições de Manutenção

## Objetivo

Inventariar atribuições e execuções de manutenção registradas pelo Azure Update Manager.

## Fonte

`MaintenanceResources + Resources`

## Campos retornados

- Subscription e recurso-alvo
- Tipo do registro
- Maintenance Configuration ID
- Escopo de manutenção
- Correlation ID
- Datas de início e término

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

A tabela operacional retorna principalmente atribuições e execuções. Detalhes completos da configuração, como recorrência, timezone e classificações selecionadas, podem exigir correlação adicional com o recurso `Microsoft.Maintenance/maintenanceConfigurations`.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática com base no esquema público do Azure Update Manager.
- Execução no tenant: **não realizada**
