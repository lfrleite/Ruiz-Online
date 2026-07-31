# Recursos Criados nas Últimas 48 Horas

## Objetivo

Localizar eventos de criação de recursos registrados no Azure Resource Graph durante as últimas 48 horas, incluindo informações da operação e da identidade responsável quando disponíveis.

## Fonte

- `ResourceChanges`
- `ResourceContainers`, utilizada para obter o nome da subscription

## Campos retornados

- Nome e ID da subscription
- Nome, tipo e Resource Group do recurso
- Data de criação em UTC
- Data convertida para GMT-3
- Data formatada como `dd-MM-yyyy_HH-mm-ss`
- Identidade responsável e tipo da identidade
- Cliente de origem
- Operação
- Correlation ID
- Resource ID

## Execução

Execute o arquivo `query.kql` no Azure Resource Graph Explorer, Azure CLI com `az graph query` ou Azure PowerShell com `Search-AzGraph`.

### Filtro opcional por subscription

O arquivo `query.kql` contém o bloco abaixo comentado no topo. Para ativá-lo, remova `//` e mantenha o filtro imediatamente após a linha `ResourceChanges`:

```kusto
// Para filtrar por subscriptions, insira após a linha "ResourceChanges":
// | where subscriptionId in (
//     'SUBSCRIPTION-ID-1',
//     'SUBSCRIPTION-ID-2'
// )
```

## Limitações

- `changedBy`, `changedByType` e `clientType` podem retornar valores vazios ou não especificados.
- O nome e o Resource Group são derivados do Resource ID e podem exigir revisão para recursos filhos ou identificadores com estrutura diferente.
- A consulta não realiza associação com `Resources`; portanto, não retorna localização, tags ou configuração atual do recurso.
- O histórico disponível depende da retenção da tabela `ResourceChanges`.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática da tabela, filtro temporal e campos projetados.
- Execução no tenant: **não realizada**
