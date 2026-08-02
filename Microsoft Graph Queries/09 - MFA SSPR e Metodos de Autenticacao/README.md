# MFA, SSPR e Métodos de Autenticação

## Objetivo

Identificar registro e capacidade de MFA, SSPR e autenticação sem senha por usuário.

## Fonte

`/reports/authenticationMethods/userRegistrationDetails`.

- Versão da API: **v1.0**, salvo chamadas opcionais documentadas.

## Arquivos

- `query.ps1`: coleta os dados e exporta CSVs em uma pasta local `output`.
- A consulta utiliza o helper público `../_Common/GraphHelpers.ps1`.

## Permissões mínimas sugeridas

- `AuditLog.Read.All`

A execução delegada também depende das funções administrativas atribuídas ao usuário autenticado. Conceda apenas as permissões necessárias.

## Principais campos retornados

- Usuário e tipo
- Indicador de administrador
- MFA registrado e capaz
- SSPR registrado e capaz
- Métodos, preferência e passwordless
- Recomendação, causa e solução

## Recomendações, causas e soluções

- Administrador sem MFA: tratar como prioridade.
- Usuário sem método forte: concluir registro e revisar métodos liberados.
- Usuário sem SSPR: validar escopo da política e registro.

Os textos calculados pela consulta são direcionadores operacionais. A decisão final deve considerar licenciamento, impacto ao usuário, exceções aprovadas e contexto do ambiente.

## Execução

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./query.ps1
```

Os arquivos exportados podem conter dados pessoais ou identificadores internos. Não publique resultados reais neste repositório.

## Limitações

Os indicadores dependem do processamento do relatório. O método registrado não garante que uma política de Acesso Condicional esteja efetivamente exigindo MFA.

## Documentação oficial

https://learn.microsoft.com/graph/api/authenticationmethodsroot-list-userregistrationdetails

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do script e da documentação oficial.
- Execução em tenant: **não realizada**
