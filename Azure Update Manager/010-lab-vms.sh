#!/usr/bin/env bash
# Artigo 010 - Ondas de patch com escopo dinâmico e TAGs
# Cria o resource group e uma VM Ubuntu por onda (DEV, HML e PRD), cada uma com a TAG da sua onda.
# Usa os mesmos nomes de resource group, VNet, subnet e NSG do laboratório do artigo 009.
# Se eles ainda existirem, são reaproveitados. Se não, são criados agora.
# Uso: ./010-lab-vms.sh
# Autenticação: use o Cloud Shell ou rode "az login" antes. Nenhuma credencial fica no script.

set -euo pipefail

RG="${RG:-rg-aum-lab-wus2-001}"
LOCATION="${LOCATION:-westus2}"
VNET="${VNET:-vnet-aum-lab-wus2-001}"
SUBNET="${SUBNET:-snet-aum-lab-wus2-001}"
NSG="${NSG:-nsg-aum-lab-wus2-001}"
IMAGE="${IMAGE:-Canonical:ubuntu-24_04-lts:server:latest}"
SIZE="${SIZE:-Standard_D2s_v5}"
TAG_KEY="${TAG_KEY:-OndaPatch}"
ONDAS="${ONDAS:-DEV HML PRD}"

trap 'echo "ERRO na linha $LINENO. Nada foi removido, corrija e rode de novo." >&2' ERR

command -v az >/dev/null 2>&1 || { echo "Azure CLI não encontrada." >&2; exit 1; }
az account show --only-show-errors --output none || { echo "Sem sessão ativa. Rode az login." >&2; exit 1; }

echo "Assinatura em uso: $(az account show --query name --output tsv)"

echo "Registrando o provider Microsoft.Maintenance..."
az provider register --namespace Microsoft.Maintenance --only-show-errors --output none

echo "Criando o resource group $RG em $LOCATION..."
az group create --name "$RG" --location "$LOCATION" --only-show-errors --output none

for ONDA in $ONDAS; do
  VM="vm-aum-$(echo "$ONDA" | tr '[:upper:]' '[:lower:]')-001"

  if az vm show --resource-group "$RG" --name "$VM" --only-show-errors --output none 2>/dev/null; then
    echo "A VM $VM já existe, seguindo para a próxima."
    continue
  fi

  echo "Criando a VM $VM com a TAG $TAG_KEY=$ONDA..."
  az vm create \
    --resource-group "$RG" \
    --name "$VM" \
    --location "$LOCATION" \
    --image "$IMAGE" \
    --size "$SIZE" \
    --admin-username azureuser \
    --generate-ssh-keys \
    --vnet-name "$VNET" \
    --subnet "$SUBNET" \
    --nsg "$NSG" \
    --nsg-rule NONE \
    --public-ip-address "pip-$VM" \
    --public-ip-sku Standard \
    --tags "$TAG_KEY=$ONDA" Ambiente=Lab \
    --only-show-errors \
    --output none
done

echo "VMs do laboratório:"
az vm list \
  --resource-group "$RG" \
  --query "[].{Nome:name, Onda:tags.$TAG_KEY, SO:storageProfile.osDisk.osType}" \
  --output table

echo "Estado do provider Microsoft.Maintenance: $(az provider show --namespace Microsoft.Maintenance --query registrationState --output tsv)"
