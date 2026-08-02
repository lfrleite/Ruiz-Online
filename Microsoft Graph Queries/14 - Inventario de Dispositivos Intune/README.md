# Inventário de Dispositivos Intune

## Objetivo

Exportar inventário técnico, gerenciamento, compliance, criptografia, ameaça e último check-in dos dispositivos gerenciados.

## Fonte

`/deviceManagement/managedDevices`.

- Versão da API: **v1.0**, salvo chamadas opcionais documentadas.

## Arquivos

- `query.ps1`: coleta os dados e exporta CSVs em uma pasta local `output`.
- A consulta utiliza o helper público `../_Common/GraphHelpers.ps1`.

## Permissões mínimas sugeridas

- `DeviceManagementManagedDevices.Read.All`

A execução delegada também depende das funções administrativas atribuídas ao usuário autenticado. Conceda apenas as permissões necessárias.

## Principais campos retornados

- Identidade do dispositivo e usuário
- Sistema, versão, fabricante e modelo
- Ownership, agente e enrollment
- Compliance, criptografia e ameaça
- Última sincronização

## Recomendações, causas e soluções

- Não conforme: correlacionar com configuração específica.
- Sem criptografia: validar política e suporte.
- Sem check-in recente: investigar conectividade, aposentadoria ou objeto obsoleto.

Os textos calculados pela consulta são direcionadores operacionais. A decisão final deve considerar licenciamento, impacto ao usuário, exceções aprovadas e contexto do ambiente.

## Execução

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./query.ps1
```

Os arquivos exportados podem conter dados pessoais ou identificadores internos. Não publique resultados reais neste repositório.

## Limitações

Campos variam conforme plataforma e agente. O resultado contém dados pessoais e números de série.

## Documentação oficial

https://learn.microsoft.com/graph/api/intune-devices-manageddevice-list

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do script e da documentação oficial.
- Execução em tenant: **não realizada**
