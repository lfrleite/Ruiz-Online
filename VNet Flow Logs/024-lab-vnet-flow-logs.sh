#!/usr/bin/env bash
# Artigo 024 - Migrando de NSG flow logs para VNet flow logs
# Monta o laboratorio: VNet, NSG, duas VMs Linux, storage account e workspace.
# O VNet flow log em si e criado no Passo 4 do artigo (portal ou CLI).
#
# Uso:
#   az login
#   bash 024-lab-vnet-flow-logs.sh <nome-da-storage-account>
#
# O nome da storage account e global: 3 a 24 caracteres, so minusculas e numeros.
# Nenhuma credencial fica no script. As VMs usam chave SSH gerada pelo az.

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Uso: bash 024-lab-vnet-flow-logs.sh <nome-da-storage-account>" >&2
  exit 1
fi

STORAGE="$1"
if ! [[ "$STORAGE" =~ ^[a-z0-9]{3,24}$ ]]; then
  echo "ERRO: nome de storage account invalido: $STORAGE" >&2
  exit 1
fi

if ! az account show >/dev/null 2>&1; then
  echo "ERRO: sem sessao ativa. Rode 'az login' antes." >&2
  exit 1
fi

# ---------- Variaveis ----------
LOCATION="westus2"
RG="rg-flowlogs-lab-wus2-001"
VNET="vnet-flowlogs-lab-wus2-001"
SUBNET="snet-flowlogs-app-wus2-001"
NSG="nsg-flowlogs-app-wus2-001"
VM1="vm-flowlogs-lab-001"
VM2="vm-flowlogs-lab-002"
VM_SIZE="Standard_B2s"   # troque se o tamanho nao estiver disponivel na sua assinatura
WORKSPACE="log-flowlogs-lab-wus2-001"

trap 'echo "ERRO na linha $LINENO. Confira a mensagem acima antes de rodar de novo." >&2' ERR

echo "1/6 Registrando o provider Microsoft.Insights..."
az provider register --namespace Microsoft.Insights

echo "2/6 Criando o resource group..."
az group create --name "$RG" --location "$LOCATION" --output none

echo "3/6 Criando NSG, regra de bloqueio e VNet..."
az network nsg create --resource-group "$RG" --name "$NSG" --location "$LOCATION" --output none

# Nega TCP 8080 dentro da VNet. Existe so para produzir fluxo negado de proposito.
az network nsg rule create --resource-group "$RG" --nsg-name "$NSG" \
  --name "Deny-TCP-8080-Inbound" --priority 200 --direction Inbound --access Deny \
  --protocol Tcp --source-address-prefixes VirtualNetwork --source-port-ranges '*' \
  --destination-address-prefixes VirtualNetwork --destination-port-ranges 8080 --output none

az network vnet create --resource-group "$RG" --name "$VNET" --location "$LOCATION" \
  --address-prefixes 10.60.0.0/16 --subnet-name "$SUBNET" --subnet-prefixes 10.60.1.0/24 \
  --nsg "$NSG" --output none

echo "4/6 Criando as VMs (leva alguns minutos)..."
# VM 001: IP publico Standard na NIC, que e um metodo explicito de saida.
# Nenhuma regra de entrada e criada: o NSG da subnet continua negando a internet.
az vm create --resource-group "$RG" --name "$VM1" --location "$LOCATION" \
  --image Ubuntu2404 --size "$VM_SIZE" --vnet-name "$VNET" --subnet "$SUBNET" \
  --nsg "" --public-ip-sku Standard --admin-username azureuser --generate-ssh-keys --output none

# VM 002: sem IP publico. Serve de destino para o trafego interno.
az vm create --resource-group "$RG" --name "$VM2" --location "$LOCATION" \
  --image Ubuntu2404 --size "$VM_SIZE" --vnet-name "$VNET" --subnet "$SUBNET" \
  --nsg "" --public-ip-address "" --admin-username azureuser --generate-ssh-keys --output none

echo "5/6 Criando a storage account (Standard, general-purpose v2)..."
az storage account create --resource-group "$RG" --name "$STORAGE" --location "$LOCATION" \
  --sku Standard_LRS --kind StorageV2 --min-tls-version TLS1_2 \
  --allow-blob-public-access false --output none

echo "6/6 Criando o Log Analytics workspace..."
az monitor log-analytics workspace create --resource-group "$RG" --name "$WORKSPACE" \
  --location "$LOCATION" --output none

echo
echo "Laboratorio pronto."
echo "Resource group : $RG"
echo "VNet           : $VNET"
echo "Storage account: $STORAGE"
echo "Workspace      : $WORKSPACE"
