# Recursos Não Conformes por Política

## Objetivo

Detalhar recursos avaliados como não conformes pelo Azure Policy, incluindo atribuição, definição e motivo retornado pela plataforma.

## Fonte

`PolicyResources`

## Campos retornados

- Subscription e Resource Group
- Resource ID e tipo do recurso avaliado
- Nome e ID da atribuição
- Nome e ID da definição
- Estado e motivo da não conformidade
- Data da avaliação

## Execução

Execute no Azure Resource Graph Explorer, Azure CLI ou Azure PowerShell.

### Filtro opcional por subscription

O arquivo `query.kql` contém o bloco abaixo comentado no topo. Para ativá-lo, remova `//` e mantenha o filtro imediatamente após a linha `PolicyResources`:

```kusto
// Para filtrar por subscriptions, insira após a linha "PolicyResources":
// | where subscriptionId in (
//     'SUBSCRIPTION-ID-1',
//     'SUBSCRIPTION-ID-2'
// )
```

## Limitações

O motivo detalhado nem sempre é preenchido de forma uniforme. Iniciativas podem gerar mais de um registro para o mesmo recurso devido às diferentes definições internas.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática com base na estrutura pública de `PolicyResources`.
- Execução no tenant: **não realizada**
