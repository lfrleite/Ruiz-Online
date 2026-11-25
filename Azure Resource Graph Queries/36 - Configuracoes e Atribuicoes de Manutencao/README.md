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

O arquivo `query.kql` contém o bloco abaixo comentado no topo. Para ativá-lo, remova `//` e mantenha o filtro imediatamente após a linha `MaintenanceResources`:

```kusto
// Para filtrar por subscriptions, insira após a linha "MaintenanceResources":
// | where subscriptionId in (
//     'SUBSCRIPTION-ID-1',
//     'SUBSCRIPTION-ID-2'
// )
```

## Limitações

A tabela operacional retorna principalmente atribuições e execuções. Detalhes completos da configuração, como recorrência, timezone e classificações selecionadas, podem exigir correlação adicional com o recurso `Microsoft.Maintenance/maintenanceConfigurations`.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **25/11/2026**
- Evidência: revisão estática com base no esquema público do Azure Update Manager.
- Execução no tenant: **não realizada**

## Revisão de 25/11/2026

Inclui configurações, atribuições e execuções; validar os tipos retornados, o suporte à união e os campos de janela e instalação. A execução no tenant permanece pendente.
