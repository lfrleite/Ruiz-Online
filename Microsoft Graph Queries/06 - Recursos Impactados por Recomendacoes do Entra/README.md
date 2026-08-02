# Recursos Impactados por Recomendações do Entra

## Objetivo

Detalhar usuários, aplicativos e outros objetos associados às recomendações do Microsoft Entra.

## Fonte

`/beta/directory/recommendations/{recommendationId}/impactedResources`.

- Versão da API: **beta**; o contrato pode mudar.

## Arquivos

- `query.ps1`: coleta os dados e exporta CSVs em uma pasta local `output`.
- A consulta utiliza o helper público `../_Common/GraphHelpers.ps1`.

## Permissões mínimas sugeridas

- `DirectoryRecommendations.Read.All`

A execução delegada também depende das funções administrativas atribuídas ao usuário autenticado. Conceda apenas as permissões necessárias.

## Principais campos retornados

- Recomendação e prioridade
- Tipo, nome e identificador do recurso
- Status, rank e datas
- Detalhes adicionais
- Portal, API e orientação de remediação

## Recomendações, causas e soluções

- Usar o recurso impactado como evidência da causa.
- Não executar remoções ou alterações automaticamente com base no CSV.
- Aplicar a solução oficial da recomendação e registrar exceções aprovadas.

Os textos calculados pela consulta são direcionadores operacionais. A decisão final deve considerar licenciamento, impacto ao usuário, exceções aprovadas e contexto do ambiente.

## Execução

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./query.ps1
```

Os arquivos exportados podem conter dados pessoais ou identificadores internos. Não publique resultados reais neste repositório.

## Limitações

A coleta pode expor nomes, IDs e URLs internas. Os resultados não devem ser publicados. A API está em beta.

## Documentação oficial

https://learn.microsoft.com/graph/api/recommendation-list-impactedresources

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do script e da documentação oficial.
- Execução em tenant: **não realizada**
