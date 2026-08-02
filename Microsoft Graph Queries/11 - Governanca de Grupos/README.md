# Governança de Grupos

## Objetivo

Identificar grupos sem proprietário, com proprietário único ou convidado, vazios, dinâmicos, sincronizados e aptos a receber funções.

## Fonte

`/groups`, `/groups/{id}/owners`, `/groups/{id}/members`, `/groupSettings` e `/policies/authorizationPolicy`.

- Versão da API: **v1.0**, salvo chamadas opcionais documentadas.

## Arquivos

- `query.ps1`: coleta os dados e exporta CSVs em uma pasta local `output`.
- A consulta utiliza o helper público `../_Common/GraphHelpers.ps1`.

## Permissões mínimas sugeridas

- `Group.Read.All`
- `GroupMember.Read.All`
- `GroupSettings.Read.All`
- `Policy.Read.All`

A execução delegada também depende das funções administrativas atribuídas ao usuário autenticado. Conceda apenas as permissões necessárias.

## Principais campos retornados

- Tipo e configuração do grupo
- Proprietários e membros
- Sincronização e expiração
- Grupo dinâmico ou role-assignable
- Configurações globais e autorização

## Recomendações, causas e soluções

- Sem proprietário: definir responsável.
- Apenas um proprietário: adicionar contingência.
- Convidado proprietário: revisar necessidade.
- Grupo vazio ou expirado: validar ciclo de vida.
- Aplicar nomenclatura, expiração e restrição de criação conforme governança.

Os textos calculados pela consulta são direcionadores operacionais. A decisão final deve considerar licenciamento, impacto ao usuário, exceções aprovadas e contexto do ambiente.

## Execução

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./query.ps1
```

Os arquivos exportados podem conter dados pessoais ou identificadores internos. Não publique resultados reais neste repositório.

## Limitações

A consulta realiza chamadas por grupo e pode levar tempo em diretórios grandes. A ausência de atividade não é inferida por este script.

## Documentação oficial

https://learn.microsoft.com/graph/api/group-list
- Proprietários: https://learn.microsoft.com/graph/api/group-list-owners
- Configurações: https://learn.microsoft.com/graph/api/group-list-settings

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do script e da documentação oficial.
- Execução em tenant: **não realizada**
