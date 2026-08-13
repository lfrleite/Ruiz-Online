# Azure Lighthouse — Delegações

## Objetivo

Inventariar definições e atribuições de registro do Azure Lighthouse para identificar tenants gerenciadores, escopos delegados e autorizações configuradas.

## Fonte

`ManagedServicesResources`

## Campos retornados

- Subscription e Resource Group
- Tipo de registro
- Registration Definition ID e nome
- Managed By Tenant ID e nome
- Managee Tenant ID e nome, quando disponível
- Provisioning State
- Descrição
- Autorizações e autorizações elegíveis
- Resource ID

## Execução

Execute no Azure Resource Graph Explorer, Azure CLI ou Azure PowerShell.

### Filtro opcional por subscription

O arquivo `query.kql` contém um bloco comentado imediatamente após `ManagedServicesResources`. Remova `//` para restringir a subscriptions específicas.

## Limitações

As propriedades disponíveis podem variar entre `registrationAssignments` e `registrationDefinitions`. A consulta expõe a configuração ARM e não substitui uma revisão detalhada de permissões e principals no tenant gerenciador.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **13/08/2026**
- Evidência: tipos `microsoft.managedservices/registrationassignments` e `registrationdefinitions` confirmados na lista oficial de recursos suportados pelo Azure Resource Graph.
- Execução no tenant: **não realizada**
