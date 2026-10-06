#!/usr/bin/env bash
# 01-lab-legado.sh
# Cria o "legado" do laboratório: um resource group e três recursos sem TAG,
# mais uma TAG na assinatura para testar a herança.
# Só recursos de rede vazios: nada de VM, disco ou IP público.
set -euo pipefail

LOCATION="westus2"
RG="rg-tags-legado-wus2-001"
VNET="vnet-tags-legado-wus2-001"
NSG="nsg-tags-legado-wus2-001"
RT="rt-tags-legado-wus2-001"

if ! SUBSCRIPTION_ID=$(az account show --query id -o tsv 2>/dev/null); then
  echo "Sem sessão ativa. Rode 'az login' e selecione a assinatura de laboratório." >&2
  exit 1
fi
echo "Assinatura em uso: $SUBSCRIPTION_ID"

echo "Criando o resource group $RG sem nenhuma TAG..."
az group create --name "$RG" --location "$LOCATION" --output none

echo "Criando VNet, NSG e route table sem TAG..."
az network vnet create --name "$VNET" --resource-group "$RG" --location "$LOCATION" \
  --address-prefixes 10.210.0.0/24 --output none
az network nsg create --name "$NSG" --resource-group "$RG" --location "$LOCATION" --output none
az network route-table create --name "$RT" --resource-group "$RG" --location "$LOCATION" --output none

echo "Marcando só o NSG com valores diferentes dos que o resource group vai receber..."
NSG_ID=$(az resource show --resource-group "$RG" --name "$NSG" \
  --resource-type Microsoft.Network/networkSecurityGroups --query id --output tsv)
az tag update --resource-id "$NSG_ID" --operation Merge \
  --tags Ambiente=Teste CentroDeCusto=CC-9999 --output none

echo "Aplicando a TAG Departamento na assinatura (Merge preserva as TAGs que já existem)..."
az tag update --resource-id "/subscriptions/$SUBSCRIPTION_ID" --operation Merge \
  --tags Departamento=TI --output none

echo "Pronto. TAGs atuais da assinatura:"
az tag list --resource-id "/subscriptions/$SUBSCRIPTION_ID" --query properties.tags
