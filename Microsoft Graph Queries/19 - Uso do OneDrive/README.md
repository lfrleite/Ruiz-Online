# Uso do OneDrive

## Objetivo

Baixar o relatório oficial de utilização do OneDrive por conta para analisar atividade, armazenamento e contas excluídas.

## Fonte

`/reports/getOneDriveUsageAccountDetail(period='D30')`.

- Versão da API: **v1.0**, salvo chamadas opcionais documentadas.

## Arquivos

- `query.ps1`: coleta os dados e exporta CSVs em uma pasta local `output`.
- A consulta utiliza o helper público `../_Common/GraphHelpers.ps1`.

## Permissões mínimas sugeridas

- `Reports.Read.All`

A execução delegada também depende das funções administrativas atribuídas ao usuário autenticado. Conceda apenas as permissões necessárias.

## Principais campos retornados

- Proprietário e URL
- Última atividade
- Arquivos e arquivos ativos
- Armazenamento utilizado e alocado
- Indicador de conta excluída

## Recomendações, causas e soluções

- Conta sem atividade: validar vínculo e retenção.
- Usuário desabilitado ou excluído com dados: executar processo de offboarding e preservação.
- Consumo elevado: revisar arquivos e capacidade.

Os textos calculados pela consulta são direcionadores operacionais. A decisão final deve considerar licenciamento, impacto ao usuário, exceções aprovadas e contexto do ambiente.

## Execução

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./query.ps1
```

Os arquivos exportados podem conter dados pessoais ou identificadores internos. Não publique resultados reais neste repositório.

## Limitações

O endpoint retorna CSV e pode ocultar nomes conforme configuração de privacidade. O relatório não descreve todos os compartilhamentos externos.

## Documentação oficial

https://learn.microsoft.com/graph/api/reportroot-getonedriveusageaccountdetail

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do script e da documentação oficial.
- Execução em tenant: **não realizada**
