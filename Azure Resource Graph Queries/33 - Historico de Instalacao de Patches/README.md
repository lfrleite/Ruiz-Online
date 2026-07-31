# Histórico de Instalação de Patches

## Objetivo

Apresentar o histórico recente de execuções do Azure Update Manager por máquina.

## Fonte

`PatchInstallationResources + Resources`

## Campos retornados

- Subscription e máquina
- Sistema operacional
- Status e datas da instalação
- Quantidades instaladas, falhas, pendentes, excluídas e não selecionadas
- Status de reinicialização
- Identificadores de manutenção e instalação
- Erros retornados

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

O Azure Update Manager mantém no ARG somente a janela recente de dados operacionais. Para retenção histórica ampliada, utilize Azure Monitor Logs ou outra solução de armazenamento.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática com base no esquema público do Azure Update Manager.
- Execução no tenant: **não realizada**
