# Avaliação de Patches por Máquina

## Objetivo

Apresentar o resultado mais recente de avaliação de atualizações por máquina Azure ou Azure Arc.

## Fonte

`PatchAssessmentResources + Resources`

## Campos retornados

- Subscription, máquina e tipo
- Sistema operacional
- Data da avaliação
- Serviço de atualização utilizado
- Reinicialização pendente
- Total e quantidade de patches por classificação
- Erros retornados

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

Os nomes das classificações podem variar entre Windows e Linux. A soma calculada utiliza as classificações mais comuns; o objeto original também é preservado em `ContagemPorClassificacao`.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática com base no esquema público do Azure Update Manager.
- Execução no tenant: **não realizada**
