# Controles do Microsoft Secure Score

## Objetivo

Correlacionar a pontuação atual de cada controle com seu perfil oficial de recomendação, causa, remediação, impacto e documentação.

## Fonte

`/security/secureScores` e `/security/secureScoreControlProfiles`.

- Versão da API: **v1.0**, salvo chamadas opcionais documentadas.

## Arquivos

- `query.ps1`: coleta os dados e exporta CSVs em uma pasta local `output`.
- A consulta utiliza o helper público `../_Common/GraphHelpers.ps1`.

## Permissões mínimas sugeridas

- `SecurityEvents.Read.All`

A execução delegada também depende das funções administrativas atribuídas ao usuário autenticado. Conceda apenas as permissões necessárias.

## Principais campos retornados

- Controle, categoria e produto
- Score atual, máximo e pontos disponíveis
- Custo de implementação e impacto ao usuário
- Ameaças mitigadas
- Descrição, remediação e URL oficial

## Recomendações, causas e soluções

- Priorizar pontos disponíveis considerando rank, custo e impacto.
- Controles depreciados devem ser excluídos de novos planos.
- A solução é obtida do perfil oficial, evitando texto inventado no relatório.

Os textos calculados pela consulta são direcionadores operacionais. A decisão final deve considerar licenciamento, impacto ao usuário, exceções aprovadas e contexto do ambiente.

## Execução

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./query.ps1
```

Os arquivos exportados podem conter dados pessoais ou identificadores internos. Não publique resultados reais neste repositório.

## Limitações

Nem todos os controles apresentam todos os metadados. O campo de score máximo pode depender do perfil e do serviço habilitado.

## Documentação oficial

https://learn.microsoft.com/graph/api/security-list-securescorecontrolprofiles
- Recurso: https://learn.microsoft.com/graph/api/resources/securescorecontrolprofile

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do script e da documentação oficial.
- Execução em tenant: **não realizada**
