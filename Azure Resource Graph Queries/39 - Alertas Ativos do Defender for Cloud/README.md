# Alertas Ativos do Defender for Cloud

## Objetivo

Listar alertas ativos do Microsoft Defender for Cloud, priorizando severidade, entidade comprometida e orientações de remediação.

## Fonte

`SecurityResources`

## Campos retornados

- Subscription
- Severidade e status
- Nome e tipo do alerta
- System Alert ID
- Entidade comprometida
- Data de geração
- Descrição, intenção e passos de remediação
- Identificadores dos recursos relacionados

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

O ARG pode sanitizar campos identificáveis e nem todos os alertas possuem a mesma estrutura. O resultado deve ser correlacionado com o Defender for Cloud para investigação e resposta.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática com base nos exemplos públicos do Defender for Cloud.
- Execução no tenant: **não realizada**
