# Falhas de Aplicativos e Enrollment do Intune

## Objetivo

Exportar eventos de troubleshooting de aplicativos para identificar padrões de falha por aplicação, dispositivo e usuário.

## Fonte

`/deviceManagement/mobileAppTroubleshootingEvents`.

- Versão da API: **v1.0**, salvo chamadas opcionais documentadas.

## Arquivos

- `query.ps1`: coleta os dados e exporta CSVs em uma pasta local `output`.
- A consulta utiliza o helper público `../_Common/GraphHelpers.ps1`.

## Permissões mínimas sugeridas

- `DeviceManagementManagedDevices.Read.All`

A execução delegada também depende das funções administrativas atribuídas ao usuário autenticado. Conceda apenas as permissões necessárias.

## Principais campos retornados

- Data e correlação
- Usuário e dispositivo
- Aplicativo e sistema operacional
- Categoria e motivo da falha
- Detalhes técnicos

## Recomendações, causas e soluções

- Agrupar falhas recorrentes por aplicativo e versão.
- Validar requisitos, método de detecção, dependências e atribuição.
- Correlacionar com enrollment e último check-in do dispositivo.

Os textos calculados pela consulta são direcionadores operacionais. A decisão final deve considerar licenciamento, impacto ao usuário, exceções aprovadas e contexto do ambiente.

## Execução

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./query.ps1
```

Os arquivos exportados podem conter dados pessoais ou identificadores internos. Não publique resultados reais neste repositório.

## Limitações

Nem todos os eventos de enrollment aparecem nesta coleção específica. Para investigação completa, complemente com o portal e logs do dispositivo.

## Documentação oficial

https://learn.microsoft.com/graph/api/intune-devices-mobileapptroubleshootingevent-list

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do script e da documentação oficial.
- Execução em tenant: **não realizada**
