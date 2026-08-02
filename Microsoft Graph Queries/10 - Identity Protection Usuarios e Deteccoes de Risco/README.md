# Identity Protection — Usuários e Detecções de Risco

## Objetivo

Correlacionar usuários arriscados com detecções de risco para apoiar investigação e remediação.

## Fonte

`/identityProtection/riskyUsers` e `/identityProtection/riskDetections`.

- Versão da API: **v1.0**, salvo chamadas opcionais documentadas.

## Arquivos

- `query.ps1`: coleta os dados e exporta CSVs em uma pasta local `output`.
- A consulta utiliza o helper público `../_Common/GraphHelpers.ps1`.

## Permissões mínimas sugeridas

- `IdentityRiskyUser.Read.All`
- `IdentityRiskEvent.Read.All`

A execução delegada também depende das funções administrativas atribuídas ao usuário autenticado. Conceda apenas as permissões necessárias.

## Principais campos retornados

- Usuário, risco e estado
- Tipo, detalhe e origem da detecção
- Data, IP e localização
- Correlation ID
- Recomendação, causa e solução

## Recomendações, causas e soluções

- Risco alto não remediado: investigar imediatamente.
- Risco aberto: confirmar legitimidade e aplicar procedimento de resposta.
- Correlacionar com Conditional Access baseado em risco.

Os textos calculados pela consulta são direcionadores operacionais. A decisão final deve considerar licenciamento, impacto ao usuário, exceções aprovadas e contexto do ambiente.

## Execução

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./query.ps1
```

Os arquivos exportados podem conter dados pessoais ou identificadores internos. Não publique resultados reais neste repositório.

## Limitações

A disponibilidade dos dados depende de licenciamento e retenção do Identity Protection. O CSV contém informações sensíveis de segurança.

## Documentação oficial

https://learn.microsoft.com/graph/api/resources/identityprotection-overview

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do script e da documentação oficial.
- Execução em tenant: **não realizada**
