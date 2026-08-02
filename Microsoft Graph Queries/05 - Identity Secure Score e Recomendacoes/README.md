# Identity Secure Score e Recomendações

## Objetivo

Coletar as recomendações personalizadas do Microsoft Entra relacionadas ao Identity Secure Score.

## Fonte

`/beta/directory/recommendations` com filtro de categoria `identitySecureScore`.

- Versão da API: **beta**; o contrato pode mudar.

## Arquivos

- `query.ps1`: coleta os dados e exporta CSVs em uma pasta local `output`.
- A consulta utiliza o helper público `../_Common/GraphHelpers.ps1`.

## Permissões mínimas sugeridas

- `DirectoryRecommendations.Read.All`

A execução delegada também depende das funções administrativas atribuídas ao usuário autenticado. Conceda apenas as permissões necessárias.

## Principais campos retornados

- Prioridade, status e pontuação
- Licenças exigidas
- Áreas afetadas
- Insights e benefícios
- Etapas de ação, impacto e documentação

## Recomendações, causas e soluções

- Priorizar recomendações com maior pontuação disponível e prioridade elevada.
- Causa, solução e benefícios são obtidos diretamente dos objetos retornados pelo serviço.
- Validar licenciamento antes de classificar uma recomendação como executável.

Os textos calculados pela consulta são direcionadores operacionais. A decisão final deve considerar licenciamento, impacto ao usuário, exceções aprovadas e contexto do ambiente.

## Execução

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./query.ps1
```

Os arquivos exportados podem conter dados pessoais ou identificadores internos. Não publique resultados reais neste repositório.

## Limitações

A API de recomendações está em beta. Campos e estrutura podem mudar. Nem toda recomendação é aplicável ou licenciada para todos os tenants.

## Documentação oficial

https://learn.microsoft.com/entra/identity/monitoring-health/overview-recommendations
- API: https://learn.microsoft.com/graph/api/recommendation-list

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do script e da documentação oficial.
- Execução em tenant: **não realizada**
