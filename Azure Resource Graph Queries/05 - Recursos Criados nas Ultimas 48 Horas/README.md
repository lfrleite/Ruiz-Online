# Recursos Criados nas Últimas 48 Horas

## Objetivo

Localizar eventos de criação de recursos registrados pelo Azure Resource Graph nas últimas 48 horas, apresentando informações do recurso e da identidade responsável pela operação.

## Arquivo

- `query.kql`: consulta pronta para uso no Azure Resource Graph Explorer.

## Informações retornadas

- Subscription Name e Subscription ID
- Nome, tipo, Resource Group e localização
- Data de criação em GMT-3
- Data de criação original em UTC
- Identidade responsável pela criação
- Tipo da identidade
- Cliente de origem, como Portal, CLI ou automação, quando disponível
- Operação e Correlation ID
- Tags e Resource ID

## Formato da data

A coluna `DataCriacao` utiliza o padrão:

```text
dd-MM-yyyy_HH-mm-ss
```

O horário é convertido de UTC para GMT-3 por meio de `datetime_add('hour', -3, DataCriacaoUTC)`.

## Filtrar por subscriptions

A consulta não possui subscriptions fixas. Para limitar o escopo, adicione a etapa abaixo imediatamente após `resourcechanges`:

```kusto
| where subscriptionId in (
    'SUBSCRIPTION-ID-1',
    'SUBSCRIPTION-ID-2'
)
```

Também é possível selecionar as subscriptions diretamente no escopo do Azure Resource Graph Explorer.

## Observações

A consulta utiliza a tabela `resourcechanges` e filtra eventos cujo `changeType` seja `Create`. Informações como `CriadoPor`, `TipoCriador` e `ClienteOrigem` podem aparecer como não especificadas quando o evento ou os metadados do recurso não fornecerem a identidade responsável.

A associação com a tabela `Resources` complementa nome, localização e tags. Caso o recurso tenha sido removido logo após a criação, esses campos complementares podem ficar vazios.
