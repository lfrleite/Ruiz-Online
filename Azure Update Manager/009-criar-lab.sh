#!/usr/bin/env bash
# Laboratório do artigo "Azure Update Manager do zero"
# Cria o resource group e duas VMs (Windows Server 2022 e Ubuntu 24.04) sem regra de entrada no NSG.
# Uso: bash 009-criar-lab.sh
# Requisitos: Azure CLI autenticado (az login) ou Cloud Shell em Bash.

set -euo pipefail

RG="rg-aum-lab-wus2-001"
LOCATION="westus2"
VNET="vnet-aum-lab-wus2-001"
SUBNET="snet-aum-lab-wus2-001"
NSG="nsg-aum-lab-wus2-001"
VM_WIN="vm-aum-win-001"
VM_LNX="vm-aum-lnx-001"
VM_SIZE="Standard_D2s_v5"
ADMIN_USER="azureuser"

trap 'echo "ERRO na linha $LINENO. Nada mais foi executado depois deste ponto." >&2' ERR

if ! az account show --only-show-errors >/dev/null 2>&1; then
  echo "Sessão do Azure CLI não encontrada. Rode 'az login' e tente de novo." >&2
  exit 1
fi

echo "Assinatura em uso: $(az account show --query name -o tsv)"

echo "Registrando o provider Microsoft.Maintenance..."
az provider register --namespace Microsoft.Maintenance --only-show-errors

for i in $(seq 1 30); do
  STATE=$(az provider show --namespace Microsoft.Maintenance --query registrationState -o tsv)
  echo "  registrationState: $STATE"
  if [ "$STATE" = "Registered" ]; then
    break
  fi
  if [ "$i" -eq 30 ]; then
    echo "O provider não chegou em Registered depois de 5 minutos. Confira no portal e rode o script de novo." >&2
    exit 1
  fi
  sleep 10
done

echo "Criando o resource group $RG em $LOCATION..."
az group create --name "$RG" --location "$LOCATION" --only-show-errors --output none

# Se o script for rodado de novo, a VM que já existe é mantida como está.
if az vm show --resource-group "$RG" --name "$VM_WIN" --only-show-errors --output none 2>/dev/null; then
  echo "A VM $VM_WIN já existe, seguindo para a próxima."
else
  # A senha do administrador do Windows é digitada na hora e não fica gravada em arquivo nenhum.
  read -r -s -p "Senha do usuário $ADMIN_USER da VM Windows: " WIN_PASSWORD
  echo
  if [ -z "$WIN_PASSWORD" ]; then
    echo "Senha vazia. Abortando." >&2
    exit 1
  fi

  echo "Criando a VM Windows $VM_WIN..."
  az vm create \
    --resource-group "$RG" \
    --name "$VM_WIN" \
    --location "$LOCATION" \
    --image "MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest" \
    --size "$VM_SIZE" \
    --admin-username "$ADMIN_USER" \
    --admin-password "$WIN_PASSWORD" \
    --vnet-name "$VNET" \
    --subnet "$SUBNET" \
    --nsg "$NSG" \
    --nsg-rule NONE \
    --public-ip-address "pip-$VM_WIN" \
    --public-ip-sku Standard \
    --only-show-errors \
    --output none

  unset WIN_PASSWORD
fi

if az vm show --resource-group "$RG" --name "$VM_LNX" --only-show-errors --output none 2>/dev/null; then
  echo "A VM $VM_LNX já existe, nada a criar."
else
  echo "Criando a VM Linux $VM_LNX..."
  az vm create \
    --resource-group "$RG" \
    --name "$VM_LNX" \
    --location "$LOCATION" \
    --image "Canonical:ubuntu-24_04-lts:server:latest" \
    --size "$VM_SIZE" \
    --admin-username "$ADMIN_USER" \
    --generate-ssh-keys \
    --vnet-name "$VNET" \
    --subnet "$SUBNET" \
    --nsg "$NSG" \
    --nsg-rule NONE \
    --public-ip-address "pip-$VM_LNX" \
    --public-ip-sku Standard \
    --only-show-errors \
    --output none
fi

echo
echo "VMs criadas:"
az vm list --resource-group "$RG" --show-details \
  --query "[].{Nome:name, SO:storageProfile.osDisk.osType, Estado:powerState}" \
  --output table

echo
echo "Modo de patch com que cada VM nasceu:"
az vm show --resource-group "$RG" --name "$VM_WIN" \
  --query "osProfile.windowsConfiguration.patchSettings" --output json
az vm show --resource-group "$RG" --name "$VM_LNX" \
  --query "osProfile.linuxConfiguration.patchSettings" --output json
