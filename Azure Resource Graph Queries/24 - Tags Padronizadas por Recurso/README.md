# Tags Padronizadas por Recurso

## Objetivo

Retornar tags de governança em colunas separadas e calcular quantas tags do padrão estão preenchidas em cada recurso.

## Fonte

`Resources`

## Tags retornadas

`CC`, `AMBIENTE`, `CLIENTE`, `CCOWNER`, `CAPEX`, `DISPONIBILIDADE`, `BU`, `DOMINIO`, `ENDOFLIFE`, `FUNCAO`, `PRODUTO`, `RESERVA`, `BACKUP`, `START`, `SQUAD`, `STOP`, `WAVE` e `SO`.

## Campos adicionais

- Subscription e Resource Group
- Nome, tipo e localização do recurso
- Quantidade de tags do padrão preenchidas
- Resource ID

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

As chaves são avaliadas com a grafia definida no padrão. Tags equivalentes com diferenças de caixa, espaços ou nomes alternativos não são consolidadas automaticamente. Alguns tipos de recurso podem não oferecer suporte a tags.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática da extração e contagem das tags.
- Execução no tenant: **não realizada**
