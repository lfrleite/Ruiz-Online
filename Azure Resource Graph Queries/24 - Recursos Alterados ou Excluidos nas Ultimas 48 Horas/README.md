# Recursos Alterados ou Excluídos nas Últimas 48 Horas

## Objetivo

Identificar alterações e exclusões recentes de recursos, incluindo identidade que executou a operação, cliente de origem e correlation ID.

## Fonte

`ResourceChanges`

## Campos retornados

- Subscription
- Tipo de alteração (`Update` ou `Delete`)
- Nome e tipo do recurso
- Resource Group
- Data da alteração em UTC
- Identidade responsável e tipo
- Cliente/origem da operação
- Operação, quantidade de mudanças e correlation ID
- Resource ID

## Execução

Execute no Azure Resource Graph Explorer, Azure CLI ou Azure PowerShell.

### Filtro opcional por subscription

O arquivo `query.kql` contém um bloco comentado imediatamente após `ResourceChanges`. Remova `//` para restringir a subscriptions específicas.

## Limitações

A disponibilidade histórica segue a retenção do Change Analysis/Resource Graph. Campos de identidade podem aparecer como `System` ou `Unspecified` em alterações realizadas pela plataforma. A consulta usa os campos sob `properties.*`, conforme o schema atual de `ResourceChanges`.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **13/08/2026**
- Evidência: estrutura alinhada aos exemplos oficiais de `ResourceChanges`.
- Execução no tenant: **não realizada**
