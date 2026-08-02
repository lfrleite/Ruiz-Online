# Visão Geral do Tenant

## Objetivo

Consolidar indicadores de usuários, grupos, dispositivos, gerenciamento pelo Intune, sincronização local e domínios verificados.

## Fonte

`/organization`, `/users`, `/groups`, `/devices` e `/deviceManagement/managedDevices`.

- Versão da API: **v1.0**, salvo chamadas opcionais documentadas.

## Arquivos

- `query.ps1`: coleta os dados e exporta CSVs em uma pasta local `output`.
- A consulta utiliza o helper público `../_Common/GraphHelpers.ps1`.

## Permissões mínimas sugeridas

- `Organization.Read.All`
- `User.Read.All`
- `Group.Read.All`
- `Device.Read.All`
- `DeviceManagementManagedDevices.Read.All`

A execução delegada também depende das funções administrativas atribuídas ao usuário autenticado. Conceda apenas as permissões necessárias.

## Principais campos retornados

- Usuários por estado, tipo e origem
- Grupos Microsoft 365, de segurança e dinâmicos
- Dispositivos registrados no Entra ID
- Dispositivos gerenciados e não conformes no Intune
- Diferença entre inventários
- Sincronização on-premises e domínios

## Recomendações, causas e soluções

- Divergência Entra/Intune: revisar duplicidade, enrollment, objetos obsoletos e dispositivos não gerenciados.
- Usuários desabilitados ou convidados devem ser analisados por processo de governança, sem remoção automática.
- A coleta cria uma linha consolidada adequada para dashboards mensais.

Os textos calculados pela consulta são direcionadores operacionais. A decisão final deve considerar licenciamento, impacto ao usuário, exceções aprovadas e contexto do ambiente.

## Execução

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./query.ps1
```

Os arquivos exportados podem conter dados pessoais ou identificadores internos. Não publique resultados reais neste repositório.

## Limitações

A API não substitui análises detalhadas de inventário. Contagens dependem das permissões e da paginação concluída com sucesso.

## Documentação oficial

- Organização: https://learn.microsoft.com/graph/api/organization-get
- Dispositivos: https://learn.microsoft.com/graph/api/device-list
- Intune: https://learn.microsoft.com/graph/api/intune-devices-manageddevice-list

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do script e da documentação oficial.
- Execução em tenant: **não realizada**
