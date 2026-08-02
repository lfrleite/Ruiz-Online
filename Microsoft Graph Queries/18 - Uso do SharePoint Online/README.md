# Uso do SharePoint Online

## Objetivo

Baixar o relatório oficial de utilização por site do SharePoint para análise de atividade, armazenamento e ciclo de vida.

## Fonte

`/reports/getSharePointSiteUsageDetail(period='D30')`.

- Versão da API: **v1.0**, salvo chamadas opcionais documentadas.

## Arquivos

- `query.ps1`: coleta os dados e exporta CSVs em uma pasta local `output`.
- A consulta utiliza o helper público `../_Common/GraphHelpers.ps1`.

## Permissões mínimas sugeridas

- `Reports.Read.All`

A execução delegada também depende das funções administrativas atribuídas ao usuário autenticado. Conceda apenas as permissões necessárias.

## Principais campos retornados

- Site e proprietário
- Última atividade
- Arquivos e arquivos ativos
- Page views e páginas visitadas
- Armazenamento utilizado e alocado

## Recomendações, causas e soluções

- Site sem atividade: validar retenção, proprietário e finalidade.
- Consumo elevado: planejar capacidade e limpeza controlada.
- Proprietário ausente ou inválido: definir responsável.
- Não remover sites apenas por baixa atividade sem validação de negócio.

Os textos calculados pela consulta são direcionadores operacionais. A decisão final deve considerar licenciamento, impacto ao usuário, exceções aprovadas e contexto do ambiente.

## Execução

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./query.ps1
```

Os arquivos exportados podem conter dados pessoais ou identificadores internos. Não publique resultados reais neste repositório.

## Limitações

O endpoint retorna CSV e pode ocultar nomes conforme configuração de privacidade dos relatórios. Compartilhamento externo detalhado exige coleta adicional.

## Documentação oficial

https://learn.microsoft.com/graph/api/reportroot-getsharepointsiteusagedetail

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do script e da documentação oficial.
- Execução em tenant: **não realizada**
