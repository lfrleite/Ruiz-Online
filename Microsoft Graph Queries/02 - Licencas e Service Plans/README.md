# Licenças e Service Plans

## Objetivo

Inventariar SKUs adquiridos, consumo, disponibilidade e estado dos service plans para apoiar análises de requisitos de licenciamento.

## Fonte

`/subscribedSkus`.

- Versão da API: **v1.0**, salvo chamadas opcionais documentadas.

## Arquivos

- `query.ps1`: coleta os dados e exporta CSVs em uma pasta local `output`.
- A consulta utiliza o helper público `../_Common/GraphHelpers.ps1`.

## Permissões mínimas sugeridas

- `Organization.Read.All`

A execução delegada também depende das funções administrativas atribuídas ao usuário autenticado. Conceda apenas as permissões necessárias.

## Principais campos retornados

- SKU e Service Plan
- Unidades adquiridas, consumidas e disponíveis
- Percentual de utilização
- Estado do SKU e do plano
- Recomendação, causa e solução

## Recomendações, causas e soluções

- Consumo acima da capacidade: revisar atribuições e contratação.
- Baixa disponibilidade: acompanhar crescimento e previsão de demanda.
- Service Plan em estado diferente de sucesso: verificar dependências e licenciamento.

Os textos calculados pela consulta são direcionadores operacionais. A decisão final deve considerar licenciamento, impacto ao usuário, exceções aprovadas e contexto do ambiente.

## Execução

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./query.ps1
```

Os arquivos exportados podem conter dados pessoais ou identificadores internos. Não publique resultados reais neste repositório.

## Limitações

Os nomes comerciais das licenças não são retornados de forma amigável para todos os SKUs; pode ser necessário manter um catálogo auxiliar atualizado.

## Documentação oficial

https://learn.microsoft.com/graph/api/subscribedsku-list

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do script e da documentação oficial.
- Execução em tenant: **não realizada**
