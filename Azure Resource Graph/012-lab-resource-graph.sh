#!/usr/bin/env bash
# Arquivo: 012-lab-resource-graph.sh
# Cria um laboratório pequeno para testar as consultas do Azure Resource Graph.
# Uso: bash 012-lab-resource-graph.sh
# Pré-requisito: az login já executado e a assinatura de laboratório selecionada.

set -euo pipefail
trap 'echo "ERRO: falha na linha $LINENO. Confira a mensagem acima." >&2' ERR

RG="rg-arg-lab-wus2-001"
LOCATION="westus2"
VM_LNX="vm-arg-lnx-wus2-001"
VM_WIN="vm-arg-win-wus2-001"
DISK="disk-arg-solto-wus2-001"
PIP="pip-arg-solto-wus2-001"
NSG="nsg-arg-aberto-wus2-001"
VM_SIZE="Standard_D2s_v5"

if ! command -v az >/dev/null 2>&1; then
  echo "ERRO: Azure CLI não encontrado." >&2
  exit 1
fi

if ! az account show >/dev/null 2>&1; then
  echo "ERRO: nenhuma sessão ativa. Rode 'az login' antes." >&2
  exit 1
fi

echo "Assinatura em uso: $(az account show --query name -o tsv)"
read -r -p "Criar o laboratório nessa assinatura? (s/N) " CONFIRMA
if [[ "${CONFIRMA}" != "s" && "${CONFIRMA}" != "S" ]]; then
  echo "Cancelado."
  exit 0
fi

# A senha é digitada na hora e não fica gravada em arquivo.
read -r -s -p "Defina a senha do administrador da VM Windows: " WIN_PASSWORD
echo
if [[ -z "${WIN_PASSWORD}" ]]; then
  echo "ERRO: a senha não pode ficar vazia." >&2
  exit 1
fi

echo "Criando o resource group ${RG}..."
az group create --name "$RG" --location "$LOCATION" --output none

echo "Criando a VM Linux (com TAGs)..."
az vm create \
  --resource-group "$RG" \
  --name "$VM_LNX" \
  --location "$LOCATION" \
  --image "Canonical:ubuntu-24_04-lts:server:latest" \
  --size "$VM_SIZE" \
  --admin-username azureuser \
  --generate-ssh-keys \
  --public-ip-sku Standard \
  --nsg-rule NONE \
  --tags Ambiente=DEV Dono=infra \
  --output none

echo "Criando a VM Windows (sem TAG)..."
az vm create \
  --resource-group "$RG" \
  --name "$VM_WIN" \
  --location "$LOCATION" \
  --image "MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest" \
  --size "$VM_SIZE" \
  --admin-username azureuser \
  --admin-password "$WIN_PASSWORD" \
  --public-ip-sku Standard \
  --nsg-rule NONE \
  --output none
unset WIN_PASSWORD

echo "Desalocando a VM Windows para ter dois estados de energia..."
az vm deallocate --resource-group "$RG" --name "$VM_WIN" --output none

echo "Criando um disco que não será anexado a nenhuma VM..."
az disk create \
  --resource-group "$RG" \
  --name "$DISK" \
  --size-gb 32 \
  --sku StandardSSD_LRS \
  --output none

echo "Criando um IP público sem associação..."
az network public-ip create \
  --resource-group "$RG" \
  --name "$PIP" \
  --sku Standard \
  --output none

echo "Criando um NSG com RDP aberto para a internet (não associado a nada)..."
az network nsg create --resource-group "$RG" --name "$NSG" --output none
az network nsg rule create \
  --resource-group "$RG" \
  --nsg-name "$NSG" \
  --name Allow-RDP-Internet \
  --access Allow \
  --protocol Tcp \
  --direction Inbound \
  --priority 100 \
  --source-address-prefix Internet \
  --source-port-range "*" \
  --destination-port-range 3389 \
  --output none

echo "Laboratório criado em ${RG}. Lembre de apagar no final: az group delete --name ${RG}"
