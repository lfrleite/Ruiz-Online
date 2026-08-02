# Defender for Cloud Secure Score por Subscription

## Objetivo

Consultar o Secure Score clássico do Microsoft Defender for Cloud por subscription, incluindo pontuação, percentual, pontos disponíveis e direcionamento operacional.

## Fonte

`SecurityResources`

## Campos retornados

- Subscription
- Iniciativa
- Score atual e máximo
- Percentual
- Pontos disponíveis
- Peso
- Recomendação, causa e solução
- Documentação oficial

## Filtro opcional por subscription

O arquivo `query.kql` contém no topo o bloco comentado padrão para filtro por subscriptions.

## Limitações

Esta consulta representa o **Secure Score clássico do Defender for Cloud**, disponível no Azure Resource Graph. Ele é diferente do Cloud Secure Score baseado em risco disponível no portal Microsoft Defender. Os valores e cálculos não devem ser comparados como se fossem equivalentes.

Os limites percentuais utilizados no campo `Recomendacao` são classificações operacionais do relatório, não limites oficiais da Microsoft.

## Documentação oficial

- https://learn.microsoft.com/azure/defender-for-cloud/secure-score-security-controls
- https://learn.microsoft.com/azure/defender-for-cloud/resource-graph-samples

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Execução no tenant: **não realizada**
