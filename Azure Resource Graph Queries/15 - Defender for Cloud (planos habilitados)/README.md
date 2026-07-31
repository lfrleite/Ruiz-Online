# Defender for Cloud — Planos Habilitados

## Objetivo

Inventariar os planos do Microsoft Defender for Cloud configurados nas subscriptions, incluindo tier, subplanos, extensões, trial e possíveis pontos de revisão.

## Fonte

- `SecurityResources`
- `ResourceContainers`, utilizada para obter o nome da subscription

## Principais campos retornados

- Nome e ID da subscription
- Nome técnico e nome amigável do plano
- Pricing tier
- Subplan
- Tempo restante de trial
- Extensões configuradas
- Indicação de plano deprecated e substituto
- Data de habilitação quando disponível
- Status interpretado e recomendação inicial
- Resource ID

## Execução

Execute o arquivo `query.kql` no Azure Resource Graph Explorer, Azure CLI com `az graph query` ou Azure PowerShell com `Search-AzGraph`.

### Filtro opcional por subscription

O arquivo `query.kql` contém o bloco abaixo comentado no topo. Para ativá-lo, remova `//` e mantenha o filtro imediatamente após a linha `SecurityResources`:

```kusto
// Para filtrar por subscriptions, insira após a linha "SecurityResources":
// | where subscriptionId in (
//     'SUBSCRIPTION-ID-1',
//     'SUBSCRIPTION-ID-2'
// )
```

## Limitações

- A consulta mostra a configuração de pricing e não comprova cobertura efetiva de todos os recursos.
- Planos, subplanos e extensões podem evoluir ao longo do tempo.
- A ausência de uma extensão no campo projetado deve ser confirmada no portal ou API correspondente.
- A consulta não retorna custo, recomendações de segurança ou alertas ativos.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **31/07/2026**
- Evidência: revisão estática dos registros `microsoft.security/pricings` e campos projetados.
- Execução no tenant: **não realizada**
