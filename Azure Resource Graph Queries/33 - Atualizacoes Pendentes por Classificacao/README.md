# Atualizações Pendentes por Classificação

## Objetivo

Detalhar cada atualização identificada na avaliação mais recente do Azure Update Manager.

## Fonte

`PatchAssessmentResources + Resources`

## Campos retornados

- Subscription e máquina
- Nome da atualização
- KB ID ou versão
- Classificações
- Datas de publicação e modificação
- Necessidade e comportamento de reinicialização

## Execução

Execute no Azure Resource Graph Explorer, Azure CLI ou Azure PowerShell.

### Filtro opcional por subscription

O arquivo `query.kql` contém o bloco abaixo comentado no topo. Para ativá-lo, remova `//` e mantenha o filtro imediatamente após a linha `PatchAssessmentResources`:

```kusto
// Para filtrar por subscriptions, insira após a linha "PatchAssessmentResources":
// | where subscriptionId in (
//     'SUBSCRIPTION-ID-1',
//     'SUBSCRIPTION-ID-2'
// )
```

## Limitações

Em Linux, o KB ID normalmente não é aplicável e a data de publicação pode não ser informada pelo gerenciador de pacotes. As classificações são fornecidas pelo sistema operacional.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática com base no esquema público do Azure Update Manager.
- Execução no tenant: **não realizada**
