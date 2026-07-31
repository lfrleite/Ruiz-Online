# Inventário Completo de Recursos

## Objetivo

Inventariar recursos disponíveis no Azure Resource Graph, incluindo subscription, Resource Group, tipo, localização, SKU, zonas, tags de governança, ambiente inferido e metadados administrativos quando expostos pelo provedor.

## Fonte

- `Resources`
- `ResourceContainers`, utilizada para obter o nome da subscription

## Campos retornados

- Nome e ID da subscription
- Resource Group
- Nome, tipo, `kind` e localização do recurso
- SKU e zonas
- Recurso gerenciador
- Ambiente inferido
- Tags de ambiente, responsável, centro de custo, aplicação e criticidade
- `systemData` de criação e última modificação, quando disponível
- Todas as tags e Resource ID

## Execução

Execute o arquivo `query.kql` no Azure Resource Graph Explorer, Azure CLI com `az graph query` ou Azure PowerShell com `Search-AzGraph`.

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

- `systemData` não é preenchido de forma uniforme para todos os tipos de recurso e pode retornar valores vazios.
- O ambiente é inferido por tags, nomes e textos associados ao recurso; o resultado deve ser tratado como indicação, não como classificação definitiva.
- As variações de tags contempladas pela consulta não representam todas as convenções possíveis.
- A consulta não substitui o Azure Activity Log ou `ResourceChanges` para auditoria histórica.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática da consulta e alinhamento da documentação com os campos projetados.
- Execução no tenant: **não realizada**
