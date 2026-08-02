# Políticas de Acesso Condicional

## Objetivo

Exportar condições, inclusões, exclusões, controles de concessão e sessão das políticas de Acesso Condicional.

## Fonte

`/identity/conditionalAccess/policies`.

- Versão da API: **v1.0**, salvo chamadas opcionais documentadas.

## Arquivos

- `query.ps1`: coleta os dados e exporta CSVs em uma pasta local `output`.
- A consulta utiliza o helper público `../_Common/GraphHelpers.ps1`.

## Permissões mínimas sugeridas

- `Policy.Read.All`

A execução delegada também depende das funções administrativas atribuídas ao usuário autenticado. Conceda apenas as permissões necessárias.

## Principais campos retornados

- Estado e datas
- Usuários, grupos e funções incluídos/excluídos
- Aplicações, riscos, plataformas e localizações
- Grant e Session Controls
- Recomendação, causa e solução

## Recomendações, causas e soluções

- Report-only: analisar resultados antes da promoção.
- Desabilitada: validar se está obsoleta ou se representa lacuna.
- Sem grant control: revisar coerência da política.
- Exclusões amplas e contas de emergência devem ser revisadas manualmente.

Os textos calculados pela consulta são direcionadores operacionais. A decisão final deve considerar licenciamento, impacto ao usuário, exceções aprovadas e contexto do ambiente.

## Execução

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./query.ps1
```

Os arquivos exportados podem conter dados pessoais ou identificadores internos. Não publique resultados reais neste repositório.

## Limitações

A consulta não consegue identificar de forma confiável quais contas são de emergência apenas pelo nome. A eficácia depende da avaliação de sign-ins e do modo report-only.

## Documentação oficial

https://learn.microsoft.com/graph/api/conditionalaccessroot-list-policies

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do script e da documentação oficial.
- Execução em tenant: **não realizada**
