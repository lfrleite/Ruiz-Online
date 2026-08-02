# Session Hosts do AVD e Vínculo com VMs

## Objetivo

Documentar a abordagem correta para correlacionar Session Hosts do Azure Virtual Desktop com as máquinas virtuais correspondentes.

## Classificação técnica

Este cenário é uma **solução híbrida**. O Azure Resource Graph é adequado para consultar as VMs e suas configurações, mas os detalhes operacionais dos Session Hosts devem ser obtidos pela Desktop Virtualization REST API, Azure PowerShell ou SDK oficial.

## Fontes recomendadas

- Azure Resource Graph para inventário das máquinas virtuais.
- Desktop Virtualization REST API para Session Hosts.
- Azure PowerShell ou SDK oficial como cliente da API.

Exemplo de operação REST:

```text
GET /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.DesktopVirtualization/hostPools/{hostPoolName}/sessionHosts
```

## Campos que podem ser correlacionados

- Host Pool
- Session Host
- Resource ID da VM
- Status do Session Host
- Allow New Session
- Agent Version
- Último heartbeat
- Estado de energia da VM
- Sistema operacional
- Secure Boot, vTPM e Trusted Launch

## Limitações

Não foi criado `query.kql` porque uma consulta exclusivamente no ARG não garante heartbeat, Agent Version, sessões ativas ou Allow New Session. A correlação deve utilizar o Resource ID da VM retornado pela API do AVD.

## Status de validação

- Status: **CLASSIFICADA COMO SOLUÇÃO HÍBRIDA**
- Data da revisão: **31/07/2026**
- Query KQL criada: **não**
- Execução no tenant: **não realizada**
