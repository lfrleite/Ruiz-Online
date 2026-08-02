# Saúde dos Conectores do Intune

## Objetivo

Inventariar VPP, APNs, Mobile Threat Defense e, quando disponível, Automated Device Enrollment.

## Fonte

`/deviceAppManagement/vppTokens`, `/deviceManagement/applePushNotificationCertificate`, `/mobileThreatDefenseConnectors` e endpoint beta de DEP/ADE.

- Versão da API: **beta**; o contrato pode mudar.

## Arquivos

- `query.ps1`: coleta os dados e exporta CSVs em uma pasta local `output`.
- A consulta utiliza o helper público `../_Common/GraphHelpers.ps1`.

## Permissões mínimas sugeridas

- `DeviceManagementServiceConfig.Read.All`

A execução delegada também depende das funções administrativas atribuídas ao usuário autenticado. Conceda apenas as permissões necessárias.

## Principais campos retornados

- Tipo e estado do conector
- Conta ou organização
- Última sincronização e heartbeat
- Expiração e dias restantes
- Erro, recomendação, causa e solução

## Recomendações, causas e soluções

- Token próximo da expiração: renovar preventivamente.
- Falha de sincronização: validar credenciais, conta e conectividade.
- Parceiro MTD indisponível: revisar heartbeat e impacto no compliance.

Os textos calculados pela consulta são direcionadores operacionais. A decisão final deve considerar licenciamento, impacto ao usuário, exceções aprovadas e contexto do ambiente.

## Execução

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./query.ps1
```

Os arquivos exportados podem conter dados pessoais ou identificadores internos. Não publique resultados reais neste repositório.

## Limitações

A coleta de DEP/ADE utiliza endpoint beta e pode não estar disponível. Alguns conectores exigem licenças e permissões específicas.

## Documentação oficial

https://learn.microsoft.com/graph/api/intune-onboarding-vpptoken-list
- MTD: https://learn.microsoft.com/graph/api/intune-onboarding-mobilethreatdefenseconnector-list

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do script e da documentação oficial.
- Execução em tenant: **não realizada**
