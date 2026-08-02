# Entra Connect Sync

## Objetivo

Coletar o estado geral da sincronização local, última sincronização, objetos sincronizados e recursos opcionais beta.

## Fonte

`/organization`, `/users`, `/groups` e chamada opcional `/beta/directory/onPremisesSynchronization`.

- Versão da API: **beta**; o contrato pode mudar.

## Arquivos

- `query.ps1`: coleta os dados e exporta CSVs em uma pasta local `output`.
- A consulta utiliza o helper público `../_Common/GraphHelpers.ps1`.

## Permissões mínimas sugeridas

- `Organization.Read.All`
- `Directory.Read.All`
- `User.Read.All`
- `Group.Read.All`

A execução delegada também depende das funções administrativas atribuídas ao usuário autenticado. Conceda apenas as permissões necessárias.

## Principais campos retornados

- Sincronização habilitada
- Última sincronização e horas decorridas
- Usuários e grupos sincronizados
- Domínios verificados
- Recursos beta quando disponíveis

## Recomendações, causas e soluções

- Atraso superior ao parâmetro operacional: investigar serviço e conectores.
- Sincronização desabilitada: confirmar desenho cloud-only.
- Erros detalhados, versão do agente e Password Hash Sync exigem validação adicional no servidor/portal.

Os textos calculados pela consulta são direcionadores operacionais. A decisão final deve considerar licenciamento, impacto ao usuário, exceções aprovadas e contexto do ambiente.

## Execução

```powershell
Set-ExecutionPolicy -Scope Process Bypass
./query.ps1
```

Os arquivos exportados podem conter dados pessoais ou identificadores internos. Não publique resultados reais neste repositório.

## Limitações

O Graph estável não substitui o Entra Connect Health, logs do servidor ou Synchronization Service Manager. A chamada beta é opcional e pode falhar.

## Documentação oficial

https://learn.microsoft.com/graph/api/organization-get
- Visão geral de sincronização: https://learn.microsoft.com/entra/identity/hybrid/connect/whatis-azure-ad-connect

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **02/08/2026**
- Evidência: revisão estática do script e da documentação oficial.
- Execução em tenant: **não realizada**
