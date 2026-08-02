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

O arquivo `query.kql` contém o bloco abaixo comentado no topo. Para ativá-lo, remova `//` e mantenha o filtro imediatamente após a linha `SecurityResources`:

```kusto
// Para filtrar por subscriptions, insira após a linha "SecurityResources":
// | where subscriptionId in (
//     'SUBSCRIPTION-ID-1',
//     'SUBSCRIPTION-ID-2'
// )
```

## Limitações

Alguns campos podem ser omitidos ou sanitizados pelo ARG. A recomendação deve ser validada quanto a aplicabilidade, licenciamento e impacto antes da remediação.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática com base nos exemplos públicos do Defender for Cloud.
- Execução no tenant: **não realizada**
