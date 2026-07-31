# App Service Plans e Quantidade de Apps

## Objetivo

Inventariar App Service Plans, SKU, capacidade e quantidade de aplicações associadas, destacando planos sem workloads identificados.

## Fonte

`Resources`

## Campos retornados

- Subscription e Resource Group
- Nome e localização do plano
- SKU, camada e capacidade
- Plataforma Windows ou Linux disponível
- Quantidade e nomes das aplicações
- Indicador de plano sem aplicações

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

Um plano sem aplicações associadas no ARG deve ser tratado apenas como candidato à revisão. Dependências, slots, automações, migrações ou recursos ainda em provisionamento devem ser verificados antes de qualquer alteração.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática da correlação por `serverFarmId`.
- Execução no tenant: **não realizada**
