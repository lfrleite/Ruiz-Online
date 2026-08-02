# Azure Resource Graph Queries

Biblioteca pública de consultas para inventário, governança, segurança, operações, backup e otimização de recursos no Microsoft Azure.

## Regras da biblioteca

- Não incluir nomes de clientes, tenants, domínios, e-mails, subscriptions ou recursos reais.
- Não manter IDs reais de subscriptions dentro das consultas.
- Obter o nome da subscription dinamicamente por `ResourceContainers` quando aplicável.
- Não utilizar `let` nas consultas destinadas ao Azure Resource Graph Explorer.
- Não classificar uma consulta como testada ou validada sem evidência de execução em um tenant.
- Não forçar dados financeiros, de reservas ou APIs específicas dentro do Azure Resource Graph.
- Manter cada consulta em uma pasta com `query.kql` e `README.md`, exceto quando o README documentar formalmente que a fonte correta está fora do ARG.

## Filtro opcional por subscription

Todo arquivo `query.kql` deve manter no topo um bloco opcional comentado. Para consultas iniciadas em `Resources`, utilize exatamente o padrão abaixo:

```kusto
// Para filtrar por subscriptions, insira após a linha "Resources":
// | where subscriptionId in (
//     'SUBSCRIPTION-ID-1',
//     'SUBSCRIPTION-ID-2'
// )
```

Quando a consulta começar em outra tabela, substitua apenas o nome da linha no texto do comentário. Exemplos: `PolicyResources`, `SecurityResources`, `ResourceChanges`, `RecoveryServicesResources`, `ServiceHealthResources`, `HealthResources`, `PatchAssessmentResources`, `PatchInstallationResources`, `MaintenanceResources` ou `AdvisorResources`.

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
| 06 | Snapshots e imagens | Resources | Inventário detalhado de artefatos |
| 07 | App Service Plans com ou sem APP | Resources | Planos e workloads associados |
| 08 | App Services, Functions e runtimes | Resources | Aplicações e runtimes |
| 09 | Bancos PaaS | Resources | Serviços de dados gerenciados |
| 10 | Storage Accounts | Resources | Configuração de armazenamento |
| 11 | Recursos de Rede com impacto financeiro | Resources | Inventário de rede |
| 12 | Public IPs e NICs órfãos | Resources | Candidatos sem associação |
| 13 | Recovery Services Vaults e backup | RecoveryServicesResources | Inventário de proteção |
| 14 | Log Analytics, Application Insights e Monitor | Resources | Observabilidade |
| 15 | Defender for Cloud — planos habilitados | SecurityResources | Cobertura de planos |
| 16 | Advisor focado em FinOps | AdvisorResources | Recomendações de custo |
| 17 | Snapshots e Imagens Gerenciadas | Resources | Visão resumida e idade |
| 18 | Azure Advisor | AdvisorResources | Todas as categorias |
| 19 | VMs com Situação do Backup | Resources + RecoveryServicesResources | Correlação de proteção |
| 20 | App Service Plans e Quantidade de Apps | Resources | Contagem por plano |
| 21 | AKS — Inventário e Configurações | Resources | Configurações ARM do cluster |
| 22 | Reservas Azure e Utilização | Reservations e Cost Management APIs | Fora do ARG |
| 23 | Consumo Cost Management por Mês | Cost Management API | Fora do ARG |
| 24 | Recursos Criados em Data Específica | ResourceChanges | Data editável no arquivo |
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
| 43 | Session Hosts do AVD e Vínculo com VMs | Desktop Virtualization API + ARG | Solução híbrida, sem query.kql |
| 44 | Defender for Cloud Secure Score por Subscription | SecurityResources | Score clássico do Defender for Cloud |
| 45 | Controles do Defender for Cloud Secure Score | SecurityResources | Recursos, pontos e controles |

## Observações

A sequência numérica foi normalizada para manter um único item por número, preservando os conteúdos funcionais das consultas e documentações.

Os itens 44 e 45 representam o Secure Score clássico do Defender for Cloud disponível no Azure Resource Graph. O novo Cloud Secure Score baseado em risco, exibido no portal Microsoft Defender, utiliza outro modelo e não deve ser comparado diretamente.

As consultas estão classificadas como **REVISADAS ESTRUTURALMENTE** quando houve apenas revisão estática. Nenhuma deve ser apresentada como testada no tenant até que exista evidência real de execução e conferência dos resultados.
