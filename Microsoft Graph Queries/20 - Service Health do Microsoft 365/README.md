# Service Health do Microsoft 365

## Objetivo

Coletar saúde dos serviços, incidentes, advisories e mensagens administrativas do Microsoft 365.

## Fonte

`/admin/serviceAnnouncement/healthOverviews`, `/issues` e `/messages`.

- Versão da API: **v1.0**, salvo chamadas opcionais documentadas.

## Arquivos

- `query.ps1`: coleta os dados e exporta CSVs em uma pasta local `output`.
- A consulta utiliza o helper público `../_Common/GraphHelpers.ps1`.

## Permissões mínimas sugeridas

- `ServiceHealth.Read.All`

A execução delegada também depende das funções administrativas atribuídas ao usuário autenticado. Conceda apenas as permissões necessárias.

## Principais campos retornados

- Serviço e status
- Incidente, classificação e origem
- Impacto, datas e atualizações
- Mensagens administrativas
- Recomendação, causa e solução

## Recomendações, causas e soluções

- Serviço degradado: acompanhar issue e impacto.
- Incidente aberto: seguir atualizações e comunicar usuários.
- Mensagem com action required: registrar responsável e prazo.

Os textos calculados pela consulta são direcionadores operacionais. A decisão final deve considerar licenciamento, impacto ao usuário, exceções aprovadas e contexto do ambiente.

## Execução

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./query.ps1
```

Os arquivos exportados podem conter dados pessoais ou identificadores internos. Não publique resultados reais neste repositório.

## Limitações

Os dados representam comunicações oficiais do Microsoft 365, não o Azure Service Health. Mensagens podem conter informações específicas do tenant.

## Documentação oficial

https://learn.microsoft.com/graph/api/serviceannouncement-list-healthoverviews
- Issues: https://learn.microsoft.com/graph/api/serviceannouncement-list-issues
- Messages: https://learn.microsoft.com/graph/api/serviceannouncement-list-messages

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do script e da documentação oficial.
- Execução em tenant: **não realizada**
