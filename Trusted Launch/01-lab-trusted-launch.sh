#!/usr/bin/env bash
# 01-lab-trusted-launch.sh
# Cria o laboratório do artigo: uma VM Windows Gen2 Standard, uma VM Linux Gen2 Standard
# e uma VM Windows Gen1. Nenhuma delas nasce com Trusted Launch.
# Uso: ./01-lab-trusted-launch.sh

set -euo pipefail

RG="rg-tl-lab-wus2-001"
LOCATION="westus2"
SIZE="Standard_D2s_v5"
ADMIN_USER="azureuser"
CLI_MINIMO="2.86.0"

erro() { echo "ERRO: $*" >&2; exit 1; }
trap 'echo "Falha na linha $LINENO. Confira o que já foi criado em $RG antes de rodar de novo." >&2' ERR

command -v az >/dev/null || erro "Azure CLI não encontrado."
az account show >/dev/null 2>&1 || erro "Sessão não autenticada. Rode az login antes."

CLI_ATUAL=$(az version --query '"azure-cli"' -o tsv)
MENOR=$(printf '%s\n%s\n' "$CLI_MINIMO" "$CLI_ATUAL" | sort -V | head -n 1)
if [[ "$MENOR" != "$CLI_MINIMO" ]]; then
  erro "Azure CLI $CLI_ATUAL. Para criar VM Gen2 com --security-type Standard é preciso $CLI_MINIMO ou superior."
fi

read -r -s -p "Senha do administrador das VMs Windows: " ADMIN_PASSWORD
echo
if [[ ${#ADMIN_PASSWORD} -lt 12 ]]; then
  erro "Use uma senha com pelo menos 12 caracteres."
fi

echo "[1/4] Resource group $RG em $LOCATION"
az group create --name "$RG" --location "$LOCATION" -o none

echo "[2/4] VM Windows Server 2022 Gen2 com Security type Standard"
az vm create \
  --resource-group "$RG" \
  --name vm-tlwing2-001 \
  --location "$LOCATION" \
  --image MicrosoftWindowsServer:WindowsServer:2022-datacenter-g2:latest \
  --size "$SIZE" \
  --admin-username "$ADMIN_USER" \
  --admin-password "$ADMIN_PASSWORD" \
  --security-type Standard \
  -o none

echo "[3/4] VM Ubuntu 24.04 Gen2 com Security type Standard"
az vm create \
  --resource-group "$RG" \
  --name vm-tllnxg2-001 \
  --location "$LOCATION" \
  --image Canonical:ubuntu-24_04-lts:server:latest \
  --size "$SIZE" \
  --admin-username "$ADMIN_USER" \
  --generate-ssh-keys \
  --security-type Standard \
  -o none

echo "[4/4] VM Windows Server 2022 Gen1"
az vm create \
  --resource-group "$RG" \
  --name vm-tlwing1-001 \
  --location "$LOCATION" \
  --image MicrosoftWindowsServer:WindowsServer:2022-datacenter:latest \
  --size "$SIZE" \
  --admin-username "$ADMIN_USER" \
  --admin-password "$ADMIN_PASSWORD" \
  -o none

unset ADMIN_PASSWORD

echo "Geração de cada disco de S.O. criado:"
az disk list --resource-group "$RG" \
  --query "[].{Disco:name, Geracao:hyperVGeneration, SO:osType}" -o table
