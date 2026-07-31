# Snapshots e Imagens Gerenciadas

## Objetivo

Inventariar snapshots e imagens gerenciadas, incluindo origem, tamanho, sistema operacional e idade do artefato.

## Fonte

`Resources`

## Campos retornados

- Subscription e Resource Group
- Tipo e nome do artefato
- Localização e data de criação disponível
- Idade em dias
- Tamanho e sistema operacional
- Geração Hyper-V
- Resource ID de origem
- Estado de provisionamento e tags

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

A data de criação e o recurso de origem não são preenchidos de maneira uniforme para todos os artefatos. A ausência desses campos não confirma que a origem seja desconhecida fora do Azure Resource Graph.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática das propriedades públicas de snapshots e imagens gerenciadas.
- Execução no tenant: **não realizada**
