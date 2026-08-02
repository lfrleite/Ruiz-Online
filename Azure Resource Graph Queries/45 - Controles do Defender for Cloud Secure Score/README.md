# Controles do Defender for Cloud Secure Score

## Objetivo

Detalhar os controles do Secure Score clássico por subscription, incluindo recursos saudáveis, não saudáveis, não aplicáveis, pontos disponíveis e orientação de priorização.

## Fonte

`SecurityResources`

## Campos retornados

- Subscription
- Controle e identificador
- Recursos saudáveis, não saudáveis e não aplicáveis
- Score atual e máximo
- Percentual e pontos disponíveis
- Recomendação, causa e solução
- Documentação oficial

## Filtro opcional por subscription

O arquivo `query.kql` contém no topo o bloco comentado padrão para filtro por subscriptions.

## Recomendações

Os controles com maior quantidade de pontos disponíveis e recursos não saudáveis devem ser correlacionados com as recomendações de segurança e os recursos impactados antes da remediação.

## Limitações

A consulta retorna o modelo clássico do Defender for Cloud. A pontuação agregada entre várias subscriptions é ponderada e não corresponde a uma média aritmética simples.

## Documentação oficial

- https://learn.microsoft.com/azure/defender-for-cloud/secure-score-security-controls
- https://learn.microsoft.com/azure/defender-for-cloud/resource-graph-samples

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Execução no tenant: **não realizada**
