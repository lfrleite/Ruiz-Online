# Compliance do Intune por Configuração

## Objetivo

Consolidar configurações de compliance e detalhar dispositivos não conformes, com erro, conflito ou período de carência.

## Fonte

`/deviceManagement/deviceCompliancePolicySettingStateSummaries` e relação `deviceComplianceSettingStates`.

- Versão da API: **v1.0**, salvo chamadas opcionais documentadas.

## Arquivos

- `query.ps1`: coleta os dados e exporta CSVs em uma pasta local `output`.
- A consulta utiliza o helper público `../_Common/GraphHelpers.ps1`.

## Permissões mínimas sugeridas

- `DeviceManagementConfiguration.Read.All`

A execução delegada também depende das funções administrativas atribuídas ao usuário autenticado. Conceda apenas as permissões necessárias.

## Principais campos retornados

- Configuração e plataforma
- Contagens por estado
- Dispositivo e usuário afetado
- Período de carência
- Recomendação, causa e solução

## Recomendações, causas e soluções

- Erros: investigar avaliação e conectividade.
- Conflitos: revisar políticas concorrentes.
- Não conformidade: aplicar correção específica da configuração.
- Período de carência: acompanhar antes do vencimento.

Os textos calculados pela consulta são direcionadores operacionais. A decisão final deve considerar licenciamento, impacto ao usuário, exceções aprovadas e contexto do ambiente.

## Execução

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./query.ps1
```

Os arquivos exportados podem conter dados pessoais ou identificadores internos. Não publique resultados reais neste repositório.

## Limitações

Os estados não descrevem sempre a correção técnica completa. A solução definitiva depende da configuração e da plataforma.

## Documentação oficial

https://learn.microsoft.com/graph/api/intune-deviceconfig-devicecompliancesettingstate-list

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do script e da documentação oficial.
- Execução em tenant: **não realizada**
