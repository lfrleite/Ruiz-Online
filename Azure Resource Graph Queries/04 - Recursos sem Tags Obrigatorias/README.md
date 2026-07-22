# Recursos sem Tags Obrigatórias

## Objetivo

Identificar recursos que não atendem ao conjunto mínimo de tags definido para governança, operação e FinOps.

## Arquivo

- `query.kql`: consulta pronta para uso no Azure Resource Graph Explorer.

## Tags obrigatórias adotadas

Nesta primeira versão, a política considera obrigatórias:

- `BU`
- `CC`
- `AMBIENTE`
- `CLIENTE`
- `CCOWNER`

A consulta informa a quantidade de tags ausentes e apresenta os respectivos nomes na coluna `TagsAusentes`.

## Filtrar por subscriptions

A consulta não possui subscriptions fixas. Para limitar o escopo, adicione a etapa abaixo imediatamente após `Resources`:

```kusto
| where subscriptionId in (
    'SUBSCRIPTION-ID-1',
    'SUBSCRIPTION-ID-2'
)
```

Também é possível selecionar as subscriptions diretamente no escopo do Azure Resource Graph Explorer.

## Personalizar a política

Para incluir ou remover tags obrigatórias, ajuste as duas etapas `extend` do arquivo `query.kql`:

1. Adicione ou remova a extração da tag.
2. Ajuste `QuantidadeTagsAusentes` e `TagsAusentes`.

## Observações

Nem todos os tipos de recurso aceitam tags. Antes de usar o resultado como indicador formal de não conformidade, valide quais tipos fazem parte do escopo da política de governança da organização.
