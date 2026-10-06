#!/usr/bin/env bash
# Cria um conjunto de recursos "soltos" para testar as consultas de recursos orfaos.
# Uso: bash 01-criar-lab-orfaos.sh
# Requer: Azure CLI autenticado (az login) ou Cloud Shell.

set -euo pipefail

RG="rg-orfaos-lab-wus2-001"
LOCATION="westus2"

DISK_ORFAO="disk-orfaos-lab-wus2-001"
DISK_ORIGEM="disk-orfaos-lab-wus2-002"
SNAPSHOT="snap-orfaos-lab-wus2-001"
PIP="pip-orfaos-lab-wus2-001"
VNET="vnet-orfaos-lab-wus2-001"
SUBNET="snet-orfaos-lab-wus2-001"
NIC="nic-orfaos-lab-wus2-001"
NSG="nsg-orfaos-lab-wus2-001"
PLAN="asp-orfaos-lab-wus2-001"

if ! az account show --output none 2>/dev/null; then
  echo "Sem sessao ativa no Azure CLI. Rode 'az login' e tente de novo." >&2
  exit 1
fi

echo "Assinatura em uso: $(az account show --query name --output tsv)"

echo "[1/8] Resource group"
az group create --name "$RG" --location "$LOCATION" --output none

echo "[2/8] Disco que nunca foi anexado"
az disk create \
  --resource-group "$RG" \
  --name "$DISK_ORFAO" \
  --location "$LOCATION" \
  --size-gb 4 \
  --sku Standard_LRS \
  --output none

echo "[3/8] Disco de origem, snapshot incremental e remocao do disco"
az disk create \
  --resource-group "$RG" \
  --name "$DISK_ORIGEM" \
  --location "$LOCATION" \
  --size-gb 4 \
  --sku Standard_LRS \
  --output none

DISK_ORIGEM_ID=$(az disk show \
  --resource-group "$RG" \
  --name "$DISK_ORIGEM" \
  --query id \
  --output tsv)

az snapshot create \
  --resource-group "$RG" \
  --name "$SNAPSHOT" \
  --source "$DISK_ORIGEM_ID" \
  --incremental true \
  --output none

az disk delete \
  --resource-group "$RG" \
  --name "$DISK_ORIGEM" \
  --yes

echo "[4/8] IP publico sem associacao"
az network public-ip create \
  --resource-group "$RG" \
  --name "$PIP" \
  --location "$LOCATION" \
  --sku Standard \
  --allocation-method Static \
  --output none

echo "[5/8] VNet e subnet para a NIC"
az network vnet create \
  --resource-group "$RG" \
  --name "$VNET" \
  --location "$LOCATION" \
  --address-prefixes 10.251.0.0/16 \
  --subnet-name "$SUBNET" \
  --subnet-prefixes 10.251.1.0/24 \
  --output none

echo "[6/8] NIC sem VM"
az network nic create \
  --resource-group "$RG" \
  --name "$NIC" \
  --vnet-name "$VNET" \
  --subnet "$SUBNET" \
  --output none

echo "[7/8] NSG sem associacao"
az network nsg create \
  --resource-group "$RG" \
  --name "$NSG" \
  --location "$LOCATION" \
  --output none

echo "[8/8] App Service plan pago e vazio"
az appservice plan create \
  --resource-group "$RG" \
  --name "$PLAN" \
  --location "$LOCATION" \
  --sku B1 \
  --is-linux \
  --output none

echo
echo "Recursos criados em $RG:"
az resource list \
  --resource-group "$RG" \
  --query "[].{Nome:name, Tipo:type}" \
  --output table
