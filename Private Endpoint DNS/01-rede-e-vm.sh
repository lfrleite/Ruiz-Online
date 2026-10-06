#!/usr/bin/env bash
# Passo 1: Resource Group, VNet, duas subnets, NSG e a VM de teste.
# Uso: ./01-rede-e-vm.sh <IPv4 público de onde o SSH vai sair>
# Exemplo: ./01-rede-e-vm.sh 203.0.113.10
# O IP é informado por você. O script não consulta nenhum serviço externo.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/00-variaveis.sh"

ORIGEM_SSH="${1:-}"
if [ -z "$ORIGEM_SSH" ]; then
  echo "ERRO: informe o IP público de onde você vai abrir o SSH." >&2
  echo "Uso: $0 <IPv4>   (exemplo: $0 203.0.113.10)" >&2
  exit 1
fi

# Aceita um único endereço IPv4. Faixa aberta em regra de SSH não entra aqui.
ORIGEM_SSH="${ORIGEM_SSH%/32}"
if ! [[ "$ORIGEM_SSH" =~ ^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})$ ]]; then
  echo "ERRO: '$ORIGEM_SSH' não é um endereço IPv4 único (exemplo válido: 203.0.113.10)." >&2
  exit 1
fi
for OCTETO in "${BASH_REMATCH[@]:1}"; do
  if [ "$((10#$OCTETO))" -gt 255 ]; then
    echo "ERRO: '$ORIGEM_SSH' não é um endereço IPv4 válido." >&2
    exit 1
  fi
done
case "$ORIGEM_SSH" in
  0.*|10.*|127.*|169.254.*|192.168.*|172.1[6-9].*|172.2[0-9].*|172.3[01].*)
    echo "ERRO: '$ORIGEM_SSH' não é um IP público. A regra precisa do IP de saída para a internet." >&2
    exit 1
    ;;
esac
ORIGEM_SSH="$ORIGEM_SSH/32"

echo ">> Resource Group $RG em $LOCATION"
az group create --name "$RG" --location "$LOCATION" --output none

echo ">> VNet $VNET e subnet das VMs"
az network vnet create \
  --resource-group "$RG" \
  --location "$LOCATION" \
  --name "$VNET" \
  --address-prefixes 10.60.0.0/16 \
  --subnet-name "$SNET_VM" \
  --subnet-prefixes 10.60.1.0/24 \
  --output none

echo ">> Subnet dos Private Endpoints"
az network vnet subnet create \
  --resource-group "$RG" \
  --vnet-name "$VNET" \
  --name "$SNET_PE" \
  --address-prefixes 10.60.2.0/24 \
  --output none

echo ">> NSG $NSG liberando SSH somente para $ORIGEM_SSH"
az network nsg create --resource-group "$RG" --name "$NSG" --output none
az network nsg rule create \
  --resource-group "$RG" \
  --nsg-name "$NSG" \
  --name AllowSSH \
  --priority 1000 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --destination-port-ranges 22 \
  --source-address-prefixes "$ORIGEM_SSH" \
  --output none

echo ">> VM $VM (Ubuntu 24.04, chave SSH gerada em ~/.ssh)"
az vm create \
  --resource-group "$RG" \
  --name "$VM" \
  --image Ubuntu2404 \
  --size Standard_B2s \
  --vnet-name "$VNET" \
  --subnet "$SNET_VM" \
  --nsg "$NSG" \
  --public-ip-sku Standard \
  --admin-username azureuser \
  --generate-ssh-keys \
  --output none

VM_IP="$(az vm show --show-details --resource-group "$RG" --name "$VM" --query publicIps --output tsv)"
echo
echo "Pronto. IP público da VM de teste: $VM_IP"
