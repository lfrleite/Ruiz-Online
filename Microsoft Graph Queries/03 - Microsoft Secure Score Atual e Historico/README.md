# Microsoft Secure Score Atual e Histórico

## Objetivo

Coletar o histórico diário do Microsoft Secure Score, sua pontuação, percentual, usuários, serviços e controles avaliados.

## Fonte

`/security/secureScores`.

- Versão da API: **v1.0**, salvo chamadas opcionais documentadas.

## Arquivos

- `query.ps1`: coleta os dados e exporta CSVs em uma pasta local `output`.
- A consulta utiliza o helper público `../_Common/GraphHelpers.ps1`.

## Permissões mínimas sugeridas

- `SecurityEvents.Read.All`

A execução delegada também depende das funções administrativas atribuídas ao usuário autenticado. Conceda apenas as permissões necessárias.

## Principais campos retornados

- Score atual e máximo
- Percentual e variação entre avaliações
- Usuários ativos e licenciados
- Serviços habilitados
- Controles e comparações

## Recomendações, causas e soluções

- Queda de score: correlacionar alterações nos controles e serviços.
- Pontos disponíveis: priorizar controles usando impacto, custo de implementação e impacto ao usuário.
- O histórico pode alimentar gráficos de tendência de até 90 dias.

Os textos calculados pela consulta são direcionadores operacionais. A decisão final deve considerar licenciamento, impacto ao usuário, exceções aprovadas e contexto do ambiente.

## Execução

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./query.ps1
```

Os arquivos exportados podem conter dados pessoais ou identificadores internos. Não publique resultados reais neste repositório.

## Limitações

O Microsoft Secure Score é diferente do Secure Score clássico do Defender for Cloud. O histórico disponibilizado pela API é limitado pelo serviço.

## Documentação oficial

https://learn.microsoft.com/graph/api/security-list-securescores
- Recurso: https://learn.microsoft.com/graph/api/resources/securescore

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do script e da documentação oficial.
- Execução em tenant: **não realizada**
