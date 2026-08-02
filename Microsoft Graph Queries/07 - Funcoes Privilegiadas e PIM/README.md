# Funções Privilegiadas e PIM

## Objetivo

Inventariar atribuições administrativas ativas e elegíveis, incluindo duração, escopo, principal e função.

## Fonte

`/roleManagement/directory/roleAssignmentScheduleInstances` e `/roleEligibilityScheduleInstances`.

- Versão da API: **v1.0**, salvo chamadas opcionais documentadas.

## Arquivos

- `query.ps1`: coleta os dados e exporta CSVs em uma pasta local `output`.
- A consulta utiliza o helper público `../_Common/GraphHelpers.ps1`.

## Permissões mínimas sugeridas

- `RoleManagement.Read.Directory`
- `RoleAssignmentSchedule.Read.Directory`
- `RoleEligibilitySchedule.Read.Directory`

A execução delegada também depende das funções administrativas atribuídas ao usuário autenticado. Conceda apenas as permissões necessárias.

## Principais campos retornados

- Principal e tipo
- Função e indicador de privilégio
- Atribuição ativa ou elegível
- Escopo, início, término e permanência
- Recomendação, causa e solução

## Recomendações, causas e soluções

- Atribuição privilegiada ativa e permanente: avaliar PIM e expiração.
- Convidado com função administrativa: revisar necessidade e controles compensatórios.
- Aplicar menor privilégio, aprovação e MFA para ativação.

Os textos calculados pela consulta são direcionadores operacionais. A decisão final deve considerar licenciamento, impacto ao usuário, exceções aprovadas e contexto do ambiente.

## Execução

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./query.ps1
```

Os arquivos exportados podem conter dados pessoais ou identificadores internos. Não publique resultados reais neste repositório.

## Limitações

A consulta não comprova, isoladamente, que a atribuição seja inadequada. A classificação de privilégio pode variar conforme funções personalizadas.

## Documentação oficial

https://learn.microsoft.com/graph/api/rbacapplication-list-roleassignmentscheduleinstances
- Elegibilidade: https://learn.microsoft.com/graph/api/rbacapplication-list-roleeligibilityscheduleinstances

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do script e da documentação oficial.
- Execução em tenant: **não realizada**
