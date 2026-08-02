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

O arquivo `query.kql` contém o bloco abaixo comentado no topo. Para ativá-lo, remova `//` e mantenha o filtro imediatamente após a linha `Resources`:

```kusto
// Para filtrar por subscriptions, insira após a linha "Resources":
// | where subscriptionId in (
//     'SUBSCRIPTION-ID-1',
//     'SUBSCRIPTION-ID-2'
// )
```

## Limitações

Um plano sem aplicações associadas no ARG deve ser tratado apenas como candidato à revisão. Dependências, slots, automações, migrações ou recursos ainda em provisionamento devem ser verificados antes de qualquer alteração.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática da correlação por `serverFarmId`.
- Execução no tenant: **não realizada**
