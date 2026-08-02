# Falhas de Instalação de Atualizações

## Objetivo

Listar patches individuais cujo estado de instalação foi retornado como falha pelo Azure Update Manager.

## Fonte

`PatchInstallationResources + Resources`

## Campos retornados

- Subscription e máquina
- Nome da atualização
- KB ID ou versão
- Classificações
- Estado da instalação
- Datas de publicação e modificação
- Necessidade de reinicialização

## Execução

Execute no Azure Resource Graph Explorer, Azure CLI ou Azure PowerShell.

### Filtro opcional por subscription

O arquivo `query.kql` contém o bloco abaixo comentado no topo. Para ativá-lo, remova `//` e mantenha o filtro imediatamente após a linha `PatchInstallationResources`:

```kusto
// Para filtrar por subscriptions, insira após a linha "PatchInstallationResources":
// | where subscriptionId in (
//     'SUBSCRIPTION-ID-1',
//     'SUBSCRIPTION-ID-2'
// )
```

## Limitações

A consulta detalha os patches marcados como `Failed`, mas a mensagem consolidada do erro pode estar apenas no registro resumido da instalação. Utilize em conjunto com o item 34.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática com base no esquema público do Azure Update Manager.
- Execução no tenant: **não realizada**
