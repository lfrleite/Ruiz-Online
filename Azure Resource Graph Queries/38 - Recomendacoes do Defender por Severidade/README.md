# Recomendações do Defender por Severidade

## Objetivo

Listar assessments e recomendações do Microsoft Defender for Cloud com severidade, estado, recurso avaliado e orientação de remediação.

## Fonte

`SecurityResources`

## Campos retornados

- Subscription
- Nome e ID da recomendação
- Estado e severidade
- Categorias, descrição e remediação
- Esforço de implementação e impacto ao usuário
- Recurso avaliado
- Policy Definition e link do portal

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

Alguns campos podem ser omitidos ou sanitizados pelo ARG. A recomendação deve ser validada quanto a aplicabilidade, licenciamento e impacto antes da remediação.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática com base nos exemplos públicos do Defender for Cloud.
- Execução no tenant: **não realizada**
