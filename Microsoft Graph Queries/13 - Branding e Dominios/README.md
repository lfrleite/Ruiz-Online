# Branding e Domínios

## Objetivo

Inventariar branding organizacional e domínios verificados do Microsoft Entra ID.

## Fonte

`/organization` e `/organization/{id}/branding`.

- Versão da API: **v1.0**, salvo chamadas opcionais documentadas.

## Arquivos

- `query.ps1`: coleta os dados e exporta CSVs em uma pasta local `output`.
- A consulta utiliza o helper público `../_Common/GraphHelpers.ps1`.

## Permissões mínimas sugeridas

- `Organization.Read.All`
- `OrganizationalBranding.Read.All`

A execução delegada também depende das funções administrativas atribuídas ao usuário autenticado. Conceda apenas as permissões necessárias.

## Principais campos retornados

- Domínio, tipo e estado
- Domínio padrão e inicial
- Branding configurado
- Textos e cor disponíveis
- Recomendação, causa e solução

## Recomendações, causas e soluções

- Branding ausente: avaliar identidade visual aprovada.
- Domínio não verificado ou obsoleto: revisar ciclo de vida.
- Não publicar imagens ou textos internos coletados.

Os textos calculados pela consulta são direcionadores operacionais. A decisão final deve considerar licenciamento, impacto ao usuário, exceções aprovadas e contexto do ambiente.

## Execução

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./query.ps1
```

Os arquivos exportados podem conter dados pessoais ou identificadores internos. Não publique resultados reais neste repositório.

## Limitações

A API pode responder que o branding não existe. O script não baixa os binários de imagens.

## Documentação oficial

https://learn.microsoft.com/graph/api/organizationalbranding-get
- Organização: https://learn.microsoft.com/graph/api/organization-get

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do script e da documentação oficial.
- Execução em tenant: **não realizada**
