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

```kusto
| where subscriptionId in~ (
    '00000000-0000-0000-0000-000000000000',
    '11111111-1111-1111-1111-111111111111'
)
```

## Limitações

O Azure Update Manager mantém no ARG somente a janela recente de dados operacionais. Para retenção histórica ampliada, utilize Azure Monitor Logs ou outra solução de armazenamento.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática com base no esquema público do Azure Update Manager.
- Execução no tenant: **não realizada**
