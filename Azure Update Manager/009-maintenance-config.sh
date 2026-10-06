#!/usr/bin/env bash
# Laboratório do artigo "Azure Update Manager do zero"
# Cria a maintenance configuration com escopo Guest (InGuestPatch) e associa as duas VMs do laboratório.
# Uso: bash 009-maintenance-config.sh
# Requisitos: Azure CLI autenticado e as VMs já em Customer Managed Schedules (Passo 4 do artigo).

set -euo pipefail

RG="rg-aum-lab-wus2-001"
LOCATION="westus2"
MC="mc-aum-lab-wus2-001"
VMS=("vm-aum-win-001" "vm-aum-lnx-001")
TIME_ZONE="E. South America Standard Time"
DURATION="02:00"
RECURRENCE="Day"

trap 'echo "ERRO na linha $LINENO. Nada mais foi executado depois deste ponto." >&2' ERR

if ! az account show --only-show-errors >/dev/null 2>&1; then
  echo "Sessão do Azure CLI não encontrada. Rode 'az login' e tente de novo." >&2
  exit 1
fi

# A janela precisa começar pelo menos 15 minutos depois da criação do agendamento.
# Aqui ela começa em 30 minutos, no horário de Brasília, que é o fuso informado em TIME_ZONE.
START=$(TZ="America/Sao_Paulo" date -d "+30 minutes" "+%Y-%m-%d %H:%M")
echo "Início da primeira janela: $START ($TIME_ZONE)"

echo "Conferindo o modo de patch das VMs..."
for VM in "${VMS[@]}"; do
  OS=$(az vm show --resource-group "$RG" --name "$VM" --query "storageProfile.osDisk.osType" -o tsv)
  if [ "$OS" = "Windows" ]; then
    CFG="windowsConfiguration"
  else
    CFG="linuxConfiguration"
  fi
  MODE=$(az vm show --resource-group "$RG" --name "$VM" \
    --query "osProfile.$CFG.patchSettings.patchMode" -o tsv)
  BYPASS=$(az vm show --resource-group "$RG" --name "$VM" \
    --query "osProfile.$CFG.patchSettings.automaticByPlatformSettings.bypassPlatformSafetyChecksOnUserSchedule" -o tsv)
  echo "  $VM: patchMode=$MODE bypassPlatformSafetyChecksOnUserSchedule=$BYPASS"
  if [ "$MODE" != "AutomaticByPlatform" ] || [ "$BYPASS" != "true" ]; then
    echo "A VM $VM não está em Customer Managed Schedules. Ajuste em Update settings antes de seguir." >&2
    exit 1
  fi
done

echo "Criando a maintenance configuration $MC..."
az maintenance configuration create \
  --resource-group "$RG" \
  --resource-name "$MC" \
  --location "$LOCATION" \
  --maintenance-scope InGuestPatch \
  --maintenance-window-start-date-time "$START" \
  --maintenance-window-duration "$DURATION" \
  --maintenance-window-time-zone "$TIME_ZONE" \
  --maintenance-window-recur-every "$RECURRENCE" \
  --reboot-setting IfRequired \
  --install-patches-windows-parameters classifications-to-include="[Critical,Security]" \
  --install-patches-linux-parameters classifications-to-include="[Critical,Security]" \
  --extension-properties InGuestPatchMode="User" \
  --only-show-errors \
  --output none

MC_ID=$(az maintenance configuration show \
  --resource-group "$RG" \
  --resource-name "$MC" \
  --query id -o tsv)

for VM in "${VMS[@]}"; do
  echo "Associando $VM..."
  az maintenance assignment create \
    --resource-group "$RG" \
    --location "$LOCATION" \
    --resource-name "$VM" \
    --resource-type virtualMachines \
    --provider-name Microsoft.Compute \
    --configuration-assignment-name "$MC" \
    --maintenance-configuration-id "$MC_ID" \
    --only-show-errors \
    --output none
done

echo
echo "Associações:"
for VM in "${VMS[@]}"; do
  az maintenance assignment list \
    --provider-name Microsoft.Compute \
    --resource-group "$RG" \
    --resource-name "$VM" \
    --resource-type virtualMachines \
    --query "[].{VM:'$VM', Configuracao:name}" \
    --output table
done
