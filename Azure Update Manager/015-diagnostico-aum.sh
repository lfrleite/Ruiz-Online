#!/usr/bin/env bash
# 015-diagnostico-aum.sh
# Coleta, de fora da VM, tudo o que o Azure Update Manager precisa para funcionar.
# Somente leitura: nenhum comando deste script altera a VM.
#
# Uso: ./015-diagnostico-aum.sh -g <resource-group> -n <nome-da-vm>

set -euo pipefail

usage() {
  echo "Uso: $0 -g <resource-group> -n <nome-da-vm>" >&2
  exit 1
}

RG=""
VM=""
while getopts ":g:n:" opt; do
  case "$opt" in
    g) RG="$OPTARG" ;;
    n) VM="$OPTARG" ;;
    *) usage ;;
  esac
done
[[ -z "$RG" || -z "$VM" ]] && usage

command -v az >/dev/null 2>&1 || { echo "Azure CLI não encontrado." >&2; exit 1; }
az account show >/dev/null 2>&1 || { echo "Sem sessão ativa. Rode 'az login' antes." >&2; exit 1; }

VM_ID=$(az vm show -g "$RG" -n "$VM" --query id -o tsv 2>/dev/null) || {
  echo "VM '$VM' não encontrada no resource group '$RG'." >&2
  exit 1
}

secao() { printf '\n===== %s =====\n' "$1"; }

secao "1. Estado da VM"
az vm show -g "$RG" -n "$VM" -d \
  --query "{Nome:name, Regiao:location, PowerState:powerState, SO:storageProfile.osDisk.osType}" \
  -o table

secao "2. Agente da VM"
az vm get-instance-view -g "$RG" -n "$VM" \
  --query "instanceView.vmAgent.{Versao:vmAgentVersion, Status:statuses[0].displayStatus, Mensagem:statuses[0].message}" \
  -o table || echo "Não foi possível ler o status do agente."

secao "3. Extensões permitidas (allowExtensionOperations)"
ALLOW_EXT=$(az vm show -g "$RG" -n "$VM" --query "osProfile.allowExtensionOperations" -o tsv)
echo "${ALLOW_EXT:-propriedade não definida nesta VM}"

secao "4. Configuração de patch (patchSettings)"
az vm show -g "$RG" -n "$VM" \
  --query "{Windows:osProfile.windowsConfiguration.patchSettings, Linux:osProfile.linuxConfiguration.patchSettings}" \
  -o json

secao "5. Extensão de patch"
az vm get-instance-view -g "$RG" -n "$VM" \
  --query "instanceView.extensions[?contains(type, 'PatchExtension')].{Nome:name, Tipo:type, Versao:typeHandlerVersion, Status:statuses[0].displayStatus, Mensagem:statuses[0].message}" \
  -o json || echo "Não foi possível ler as extensões."

secao "6. Maintenance configurations associadas"
az maintenance assignment list \
  --provider-name Microsoft.Compute \
  --resource-group "$RG" \
  --resource-name "$VM" \
  --resource-type virtualMachines \
  --query "[].{Associacao:name, Configuracao:maintenanceConfigurationId}" \
  -o table || echo "Não foi possível listar as associações (a extensão 'maintenance' do CLI está instalada?)."

secao "7. Última avaliação e última instalação (patchStatus)"
az vm get-instance-view -g "$RG" -n "$VM" \
  --query "instanceView.patchStatus" -o json || echo "Sem patchStatus na instance view."

secao "8. Operações com falha no Activity Log (últimos 3 dias)"
az monitor activity-log list \
  --resource-id "$VM_ID" \
  --offset 3d \
  --status Failed \
  --max-events 20 \
  --query "[].{Quando:eventTimestamp, Operacao:operationName.value, Status:status.value}" \
  -o table || echo "Não foi possível consultar o Activity Log."

echo
echo "Diagnóstico concluído para $VM."
