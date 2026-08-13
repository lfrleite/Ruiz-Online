# Session Hosts do AVD e Vínculo com VMs

## Objetivo

Inventariar Session Hosts do Azure Virtual Desktop e correlacioná-los com as máquinas virtuais correspondentes para combinar estado operacional do AVD com configuração ARM da VM.

## Fonte

`DesktopVirtualizationResources` + `Resources`

## Campos retornados

- Subscription
- Host Pool e Session Host
- Status do Session Host
- Allow New Session
- Agent Version
- Último heartbeat
- Sessões ativas
- Versão de sistema operacional reportada pelo AVD
- Usuário atribuído, quando aplicável
- Estado de atualização do agente
- VM, Resource Group, região e tamanho
- Tipo de sistema operacional
- Security Type, Secure Boot e vTPM
- Provisioning State e tags da VM

## Execução

Execute no Azure Resource Graph Explorer, Azure CLI ou Azure PowerShell.

### Filtro opcional por subscription

O arquivo `query.kql` contém um bloco comentado imediatamente após `DesktopVirtualizationResources`. Remova `//` para restringir a subscriptions específicas.

## Limitações

A tabela `DesktopVirtualizationResources` suporta o tipo `microsoft.desktopvirtualization/hostpools/sessionhosts`, porém a materialização de propriedades pode variar conforme versão do serviço e disponibilidade no tenant. A correlação com a VM depende de `properties.resourceId`. A consulta não substitui a Desktop Virtualization REST API quando forem necessários detalhes não expostos pelo Azure Resource Graph.

## Status de validação

- Status: **REVISADA ESTRUTURALMENTE**
- Data da revisão: **13/08/2026**
- Evidência: tipo `microsoft.desktopvirtualization/hostpools/sessionhosts` confirmado na lista oficial de recursos suportados pelo Azure Resource Graph.
- Execução no tenant: **não realizada**
