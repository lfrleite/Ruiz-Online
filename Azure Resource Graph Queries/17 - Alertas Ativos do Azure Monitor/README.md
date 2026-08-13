# Alertas Ativos do Azure Monitor

## Objetivo

Listar alertas atualmente disparados no Azure Monitor, com severidade, estado, serviço de monitoramento, regra e recurso afetado.

## Fonte

`AlertsManagementResources`

## Campos retornados

- Subscription
- Severidade
- Estado do alerta e condição de monitoramento
- Serviço de monitoramento e tipo de sinal
- Regra do alerta
- Recurso e tipo de recurso alvo
- Data de início e última modificação
- Descrição e Alert ID

## Execução

Execute no Azure Resource Graph Explorer, Azure CLI ou Azure PowerShell.

### Filtro opcional por subscription

O arquivo `query.kql` contém um bloco comentado imediatamente após `AlertsManagementResources`. Remova `//` para restringir a subscriptions específicas.

## Limitações

A consulta considera ativo o alerta cuja `monitorCondition` está como `Fired`. O estado operacional do alerta (`New`, `Acknowledged` ou `Closed`) é retornado separadamente. A retenção e a disponibilidade dos alertas dependem do Azure Monitor Alerts Management.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **13/08/2026**
- Evidência: estrutura baseada nos exemplos oficiais do Azure Resource Graph para `AlertsManagementResources`.
- Execução no tenant: **não realizada**
