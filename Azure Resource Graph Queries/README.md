# Azure Resource Graph Queries

Biblioteca pública de consultas para inventário, governança, segurança, operações, backup e otimização de recursos no Microsoft Azure.

## Regras da biblioteca

- Não incluir nomes de clientes, tenants, domínios, e-mails, subscriptions ou recursos reais.
- Não manter IDs reais de subscriptions dentro das consultas.
- Obter o nome da subscription dinamicamente por `ResourceContainers` quando aplicável.
- Não utilizar `let` nas consultas destinadas ao Azure Resource Graph Explorer.
- Não classificar uma consulta como testada ou validada sem evidência de execução em um tenant.
- Não forçar dados financeiros, de reservas ou APIs específicas dentro do Azure Resource Graph; esses cenários ficam na biblioteca `Azure FinOps APIs`.
- Manter cada consulta em uma pasta com `query.kql` e `README.md`.
- Preferir UTC como referência temporal canônica. Conversões de fuso devem ser explicitamente nomeadas quando necessárias.
- Evitar regras de lifecycle, retirement ou suporte hardcoded dentro de consultas de inventário quando a informação depender de documentação que muda com o tempo.

## Filtro opcional por subscription

Todo arquivo `query.kql` deve manter no topo um bloco opcional comentado. Para consultas iniciadas em `Resources`, utilize exatamente o padrão abaixo:

```kusto
// Para filtrar por subscriptions, insira após a linha "Resources":
// | where subscriptionId in (
//     'SUBSCRIPTION-ID-1',
//     'SUBSCRIPTION-ID-2'
// )
```

Quando a consulta começar em outra tabela, substitua apenas o nome da linha no texto do comentário. Exemplos: `AuthorizationResources`, `AlertsManagementResources`, `AppServiceResources`, `AdvisorResources`, `PolicyResources`, `SecurityResources`, `ResourceChanges`, `RecoveryServicesResources`, `ServiceHealthResources`, `HealthResources`, `PatchAssessmentResources`, `PatchInstallationResources`, `MaintenanceResources`, `ManagedServicesResources` ou `DesktopVirtualizationResources`.

O bloco permanece comentado para que a consulta seja executada sem IDs fixos. Para ativá-lo, remova `//` das linhas do filtro e mantenha a cláusula imediatamente depois da tabela principal.

## Padrão dos READMEs

Cada README de consulta deve conter:

- Objetivo
- Fonte ou tabela principal
- Campos retornados
- Forma de execução
- Bloco opcional por subscription correspondente ao `query.kql`
- Limitações
- Status e data da validação
- Evidência de revisão ou execução

## Status de validação

- **RASCUNHO:** estrutura ainda não revisada.
- **REVISADA ESTRUTURALMENTE:** revisão estática concluída, sem execução em tenant.
- **TESTADA NO TENANT:** execução realizada e evidenciada em ambiente Azure.
- **VALIDADA:** resultado conferido funcionalmente e aprovado para uso recorrente.

## Catálogo

| Nº | Consulta | Fonte principal | Observação |
|---:|---|---|---|
| 01 | Inventário Completo de Recursos | Resources | Inventário geral |
| 02 | Resumo por Tipo de Recurso | Resources | Consolidação por tipo |
| 03 | Detalhamento de VMs | Resources | Inventário de máquinas virtuais |
| 04 | Discos gerenciados | Resources | Discos e associação |
| 05 | Recursos Criados nas Últimas 48 Horas | ResourceChanges | Histórico recente de criação |
| 06 | Snapshots e imagens | Resources | Inventário detalhado de snapshots, imagens e Compute Gallery |
| 07 | App Service Plans com ou sem APP | Resources | Planos, apps, slots e candidatos sem workload |
| 08 | App Services, Functions e runtimes | Resources + AppServiceResources | Inventário de workloads e runtimes sem lifecycle hardcoded |
| 09 | Bancos PaaS | Resources | Serviços de dados gerenciados |
| 10 | Storage Accounts | Resources | Configuração de armazenamento |
| 11 | Recursos de Rede com impacto financeiro | Resources | Inventário de rede |
| 12 | Public IPs e NICs órfãos | Resources | Candidatos sem associação |
| 13 | Recovery Services Vaults e backup | RecoveryServicesResources | Inventário de proteção |
| 14 | Log Analytics, Application Insights e Monitor | Resources | Observabilidade |
| 15 | Defender for Cloud — planos habilitados | SecurityResources | Cobertura de planos |
| 16 | RBAC — Role Assignments por Escopo | AuthorizationResources | Atribuições de função, principals e escopos |
| 17 | Alertas Ativos do Azure Monitor | AlertsManagementResources | Alertas com monitorCondition Fired |
| 18 | Azure Advisor | AdvisorResources | Todas as categorias; Cost pode ser filtrado na mesma query |
| 19 | VMs com Situação do Backup | Resources + RecoveryServicesResources | Correlação de proteção |
| 20 | App Service — Postura de Segurança | AppServiceResources + Resources | TLS, HTTPS, FTPS e Remote Debugging |
| 21 | AKS — Inventário e Configurações | Resources | Configurações ARM do cluster |
| 22 | Azure Lighthouse — Delegações | ManagedServicesResources | Registration Assignments e Definitions |
| 23 | Hierarquia Management Groups e Subscriptions | ResourceContainers | Cadeia de ancestrais por subscription |
| 24 | Recursos Alterados ou Excluídos nas Últimas 48 Horas | ResourceChanges | Updates e Deletes recentes |
| 25 | Tags Padronizadas por Recurso | Resources | Tags em colunas separadas |
| 26 | Conformidade do Azure Policy | PolicyResources | Resumo por atribuição |
| 27 | Recursos Não Conformes por Política | PolicyResources | Evidências de não conformidade |
| 28 | Atribuições e Exceções do Azure Policy | PolicyResources | Governança aplicada |
| 29 | Eventos Ativos do Service Health | ServiceHealthResources | Eventos vinculados a subscriptions |
| 30 | Retirements e Recursos Impactados | ServiceHealthResources | Correlação por Tracking ID |
| 31 | Integridade e Disponibilidade de Recursos | HealthResources + Resources | Azure Resource Health |
| 32 | Avaliação de Patches por Máquina | PatchAssessmentResources | Resumo de pendências |
| 33 | Atualizações Pendentes por Classificação | PatchAssessmentResources | Patches individuais |
| 34 | Histórico de Instalação de Patches | PatchInstallationResources | Execuções recentes |
| 35 | Falhas de Instalação de Atualizações | PatchInstallationResources | Patches com falha |
| 36 | Configurações e Atribuições de Manutenção | MaintenanceResources | Atribuições e execuções |
| 37 | Jobs de Backup com Falha | RecoveryServicesResources | Falhas e avisos recentes |
| 38 | Políticas de Backup e Retenção | RecoveryServicesResources | Agenda, retenção e associação |
| 39 | Recomendações do Defender por Severidade | SecurityResources | Assessments do Defender |
| 40 | Alertas Ativos do Defender for Cloud | SecurityResources | Alertas operacionais |
| 41 | Secure Boot, vTPM e Trusted Launch | Resources | Configuração ARM das VMs |
| 42 | Inventário de Azure Virtual Desktop | Resources | Host Pools, Workspaces, App Groups e Scaling Plans |
| 43 | Session Hosts do AVD e Vínculo com VMs | DesktopVirtualizationResources + Resources | Session Hosts e correlação com VMs |
| 44 | Defender for Cloud Secure Score por Subscription | SecurityResources | Score clássico do Defender for Cloud |
| 45 | Controles do Defender for Cloud Secure Score | SecurityResources | Recursos, pontos e controles |

## Alterações estruturais de 13/08/2026

- A consulta de Advisor focada apenas em custo foi consolidada na entrada 18 para eliminar duplicidade funcional.
- A visão resumida de snapshots/imagens foi removida em favor da entrada 06, mais completa.
- A contagem reduzida de App Service Plans foi removida em favor da entrada 07, que também considera slots.
- A antiga consulta de criação em data específica foi substituída por uma visão distinta de Updates/Deletes recentes, mantendo a entrada 05 para Create.
- A entrada 08 foi refatorada para separar inventário de runtime de regras de lifecycle.
- A entrada 43 passou a utilizar `DesktopVirtualizationResources` e agora possui `query.kql`.
- Reservas e Cost Management foram movidos para `Azure FinOps APIs`, evitando misturar fontes externas ao ARG nesta biblioteca.

## Observações

Os itens 44 e 45 representam o Secure Score clássico do Defender for Cloud disponível no Azure Resource Graph. O Cloud Secure Score baseado em risco exibido em experiências mais recentes do Microsoft Defender utiliza outro modelo e não deve ser comparado diretamente.

As consultas são classificadas como **REVISADAS ESTRUTURALMENTE** quando houve apenas revisão estática. Nenhuma deve ser apresentada como testada no tenant até que exista evidência real de execução e conferência dos resultados.
