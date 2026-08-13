# Hierarquia de Management Groups e Subscriptions

## Objetivo

Exibir a cadeia de Management Groups associada a cada subscription para apoiar governança, escopo de políticas, RBAC e organização de landing zones.

## Fonte

`ResourceContainers`

## Campos retornados

- Subscription e estado
- Nível do Management Group na cadeia de ancestrais
- Management Group ID
- Management Group Name

## Execução

Execute no Azure Resource Graph Explorer, Azure CLI ou Azure PowerShell. Para visão completa em ambientes grandes, utilize escopo de tenant ou management group quando aplicável.

### Filtro opcional por subscription

O arquivo `query.kql` contém um bloco comentado imediatamente após `ResourceContainers`. Remova `//` para restringir a subscriptions específicas.

## Limitações

A consulta retorna uma linha por ancestral de Management Group para cada subscription. Subscriptions sem cadeia de Management Groups materializada no escopo da consulta podem não gerar linhas após o `mv-expand`.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **13/08/2026**
- Evidência: estrutura baseada nos exemplos oficiais de `ResourceContainers` e `managementGroupAncestorsChain`.
- Execução no tenant: **não realizada**
